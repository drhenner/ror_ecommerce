# == Schema Information
#
# Table name: invoices
#
#  id              :integer(4)      not null, primary key
#  order_id        :integer(4)      not null
#  amount          :decimal(8, 2)   not null
#  invoice_type    :string(255)     default("Purchase"), not null
#  state           :string(255)     not null
#  active          :boolean(1)      default(TRUE), not null
#  created_at      :datetime
#  updated_at      :datetime
#  credited_amount :decimal(8, 2)   default(0.0)
#

class Invoice < ActiveRecord::Base
  has_many :payments
  has_many :batches, :as => :batchable#, :polymorphic => true
  belongs_to :order


  validates :amount,        :presence => true
  validates :invoice_type,  :presence => true
  #validates :order_id,      :presence => true

  PURCHASE  = 'Purchase'
  RMA       = 'RMA'

  INVOICE_TYPES = [PURCHASE, RMA]
  NUMBER_SEED     = 3002001004005
  CHARACTERS_SEED = 20
  #cattr_accessor :gateway

  # after_create :create_authorized_transaction

  #def create_authorized_transaction
  #
  #end
  state_machine :initial => :pending do
    state :pending
    state :authorized
    state :paid
    state :payment_declined
    state :canceled

    #after_transition :on => 'cancel', :do => :cancel_authorized_payment

    event :payment_rma do
      transition :from => :pending,
                  :to   => :refunded
    end
    event :payment_authorized do
      transition :from => :pending,
                  :to   => :authorized
      transition :from => :payment_declined,
                  :to   => :authorized
    end
    event :payment_captured do
      transition :from => :authorized,
                  :to   => :paid
    end
    event :transaction_declined do
      transition :from => :pending,
                  :to   => :payment_declined
      transition :from => :payment_declined,
                  :to   => :payment_declined
      transition :from => :authorized,
                  :to   => :authorized
    end

    event :cancel do
      transition :from => :authorized,
                  :to  => :canceled
    end
  end

  #  the full shipping address as an array compacted.
  #
  # @param [none]
  # @return [Array]  has ("name", "address1", "address2"(unless nil), "city state zip") or nil
  def order_ship_address_lines
    order.ship_address.try(:full_address_array)
  end

  #  the full order address as an array compacted.
  #
  # @param [none]
  # @return [Array]  has ("name", "address1", "address2"(unless nil), "city state zip") or nil
  def order_billing_address_lines
    order.bill_address.try(:full_address_array)
  end

  # date the invoice was created (not the date it was paid)
  #
  # @param [Optional Symbol] date format to be returned
  # @return [String] formated date
  def invoice_date(format = :us_date)
    I18n.localize(created_at, :format => format)
  end

  # invoice number
  #
  # @param [none]
  # @return [String] invoice number calculated based off the id and preset values
  def number
    (NUMBER_SEED + id).to_s(CHARACTERS_SEED)
  end

  # invoice id calculated from the id of the number
  #
  # @param [none]
  # @return [Integer] invoice id calculated based off the id and preset values
  def self.id_from_number(num)
    num.to_i(CHARACTERS_SEED) - NUMBER_SEED
  end

  # find invoice based off the invoice's number
  #
  # @param [String] invoice Number
  # @return [Invoice] invoice
  def self.find_by_number(num)
    find(id_from_number(num))##  now we can search by id which should be much faster
  end

  # make an invoice object (not saved)
  #
  # @param [Integer] order id
  # @param [Decimal] amount in dollars
  # @return [Invoice] invoice object
  def Invoice.generate(order_id, charge_amount, credited_amount = 0.0)
    Invoice.new(:order_id => order_id, :amount => charge_amount, :invoice_type => PURCHASE, :credited_amount => credited_amount)
  end

  def capture_complete_order
    now = Time.zone.now
    if batches.empty?
      # this means we never authorized just captured payment
        batch = self.batches.create()
        transaction = CreditCardCapture.new()##  This is a type of transaction
        credit = order.user.transaction_ledgers.new(:transaction_account_id => TransactionAccount::REVENUE_ID, :debit => 0,     :credit => amount, :period => "#{now.month}-#{now.year}")
        debit   = order.user.transaction_ledgers.new(:transaction_account_id => TransactionAccount::CASH_ID,   :debit => amount, :credit => 0,      :period => "#{now.month}-#{now.year}")
        transaction.transaction_ledgers.push(credit)
        transaction.transaction_ledgers.push(debit)
        batch.transactions.push(transaction)
        batch.save
    else
      batch       = batches.first
      transaction = CreditCardReceivePayment.new()

      debit   = order.user.transaction_ledgers.new(:transaction_account_id => TransactionAccount::CASH_ID,                :debit => amount, :credit => 0,       :period => "#{now.month}-#{now.year}")
      credit  = order.user.transaction_ledgers.new(:transaction_account_id => TransactionAccount::ACCOUNTS_RECEIVABLE_ID, :debit => 0,      :credit => amount,  :period => "#{now.month}-#{now.year}")

      transaction.transaction_ledgers.push(credit)
      transaction.transaction_ledgers.push(debit)

      batch.transactions.push(transaction)
      batch.save
    end
  end

  def authorize_complete_order#(amount)
    x = order.complete!
    now = Time.zone.now
    if batches.empty?
      batch = self.batches.create()
      transaction = CreditCardPayment.new()##  This is a type of transaction
      credit = order.user.transaction_ledgers.new(:transaction_account_id => TransactionAccount::REVENUE_ID, :debit => 0, :credit => amount, :period => "#{now.month}-#{now.year}")
      debit  = order.user.transaction_ledgers.new(:transaction_account_id => TransactionAccount::ACCOUNTS_RECEIVABLE_ID, :debit => amount, :credit => 0, :period => "#{now.month}-#{now.year}")
      transaction.transaction_ledgers.push(credit)
      transaction.transaction_ledgers.push(debit)
      batch.transactions.push(transaction)
      batch.save
      #puts batch.errors
    else
      raise error ###  something messed up I think
    end
  end

  def cancel_authorized_payment
    batch       = batches.first
    now = Time.zone.now
    if batch# if not we never authorized the payment
      self.cancel!
      transaction = CreditCardCancel.new()##  This is a type of transaction
      debit   = order.user.transaction_ledgers.new(:transaction_account_id => TransactionAccount::REVENUE_ID, :debit => amount, :credit => 0, :period => "#{now.month}-#{now.year}")
      credit  = order.user.transaction_ledgers.new(:transaction_account_id => TransactionAccount::ACCOUNTS_RECEIVABLE_ID, :debit => 0, :credit => amount, :period => "#{now.month}-#{now.year}")
      transaction.transaction_ledgers.push(credit)
      transaction.transaction_ledgers.push(debit)
      batch.transactions.push(transaction)
      batch.save
    end
  end

  def self.process_rma(return_amount, order)
    transaction do
      this_invoice = Invoice.new(:order => order, :amount => return_amount, :invoice_type => RMA)
      this_invoice.save
      this_invoice.complete_rma_return
      this_invoice.payment_rma!
      this_invoice
    end
  end

  def complete_rma_return
    batch       = batches.first || self.batches.create()
    now = Time.zone.now
    transaction = ReturnMerchandiseComplete.new()##  This is a type of transaction
    debit   = order.user.transaction_ledgers.new(:transaction_account_id => TransactionAccount::REVENUE_ID, :debit => amount, :credit => 0, :period => "#{now.month}-#{now.year}")
    credit  = order.user.transaction_ledgers.new(:transaction_account_id => TransactionAccount::CASH_ID, :debit => 0, :credit => amount, :period => "#{now.month}-#{now.year}")
    transaction.transaction_ledgers.push(credit)
    transaction.transaction_ledgers.push(debit)
    batch.transactions.push(transaction)
    batch.save
  end


  # call to find the confirmation_id sent by the payment processor.
  #
  # @param [none]
  # @return [String] id the payment processor sends you after authorization.
  def authorization_reference
    if authorization = payments.find_by_action_and_success('authorization', true, :order => 'id ASC')
      authorization.confirmation_id #reference
    end
  end

  # call to find out if the transaction has succeeded.
  #
  # @param [none]
  # @return [Boolean] returns true if the invoice is paid or has been authorized for payment
  def succeeded?
    authorized? || paid?
  end

  # call to find out the amount of the invoice in cents
  #
  # @param [none]
  # @return [Integer] amount of the invoice in cents
  def integer_amount
    times_x_amount = amount.integer? ? 1 : 100
    (amount * times_x_amount).to_i
  end

  def authorize_payment(credit_card, options = {})
    options[:number] ||= unique_order_number
    transaction do
      authorization = Payment.authorize(integer_amount, credit_card, options)
      payments.push(authorization)
      if authorization.success?
        payment_authorized!
        authorize_complete_order
      else
        transaction_declined!
      end
      authorization
    end
  end

  def capture_payment(options = {})
    transaction do
      capture = Payment.capture(integer_amount, authorization_reference, options)
      payments.push(capture)
      if capture.success?
        payment_captured!
        capture_complete_order
      else
        transaction_declined!
      end
      capture
    end
  end

  # find the user id of the order associated to the invoice.
  #
  # @param [none]
  # @return [Integer] represents the id of the user
  def user_id
    order.user_id
  end

  # find the user of the order associated to the invoice.
  #
  # @param [none]
  # @return [User]
  def user
    order.user
  end

  private

  def unique_order_number
    "#{Time.now.to_i}-#{rand(1000000)}"
  end
end
