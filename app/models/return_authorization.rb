# == Schema Information
#
# Table name: return_authorizations
#
#  id             :integer(4)      not null, primary key
#  number         :string(255)
#  amount         :decimal(8, 2)   not null
#  restocking_fee :decimal(8, 2)   default(0.0)
#  order_id       :integer(4)      not null
#  user_id        :integer(4)      not null
#  state          :string(255)     not null
#  created_by     :integer(4)
#  active         :boolean(1)      default(TRUE)
#  created_at     :datetime
#  updated_at     :datetime
#

class ReturnAuthorization < ApplicationRecord
  include AASM

  has_many   :return_items
  has_many   :comments, :as => :commentable

  belongs_to :user
  belongs_to :order
  belongs_to :author, :class_name => 'User', :foreign_key => :created_by
  # has_many :transactions
  has_many    :transaction_ledgers, :as => :accountable

  accepts_nested_attributes_for :return_items,  :reject_if => proc { |attributes| attributes['return_reason_id'].blank? ||
                                                                                  attributes['return_condition_id'].blank? }
  accepts_nested_attributes_for :comments,      :reject_if => proc { |attributes| attributes['note'].blank? }

  #validates :number,      presence: true
  validates :amount,      presence:     true,
                          numericality: true

  validates :restocking_fee, :numericality => true, :allow_nil => true

  validates :user_id,     presence: true
  validates :order_id,    presence: true
  validates :created_by,  presence: true
  validate :ensure_refund_is_larger_than_restocking

  after_create      :save_order_number

  NUMBER_SEED     = 1002003004005
  CHARACTERS_SEED = 21

  ## after you process an RMA you must manually add the variant back into the system!!!
  aasm column: :state do
    state :authorized , initial: true
    state :received
    state :cancelled
    state :complete

    #after_transition :to => 'received', :do => :process_receive
    #after_transition :to => 'cancelled', :do => :process_canceled
    #before_transition :to => 'complete', :do => [:process_ledger_transactions, :mark_items_returned]

    event :receive do
      transitions to: :received, from: :authorized
    end

    event :cancel do
      transitions to: :cancelled, from: :authorized
    end

    event :complete, before: [:process_ledger_transactions, :mark_items_returned] do # do this after a payment was returned to the customer
      transitions to: :complete, from: [:authorized, :received]
    end
  end

  # when the RMA is returned, before the ReturnAuthorization transitions to complete
  #    the accounting peice logs the transactions.
  #
  # @param [none]
  # @return [none]
  def process_ledger_transactions
    ##  credit => cash
    ##  debit  => revenue
    Invoice.process_rma(amount - restocking_fee, order )
  end

  def mark_items_returned
    return_items.map(&:mark_returned!)
  end

  # number of the order that is returning the item
  #
  # @param [none]
  # @return [String]
  def order_number
    order.number
  end

  # name of the user that is returning the item
  #
  # @param [none]
  # @return [String]
  def user_name
    user.name
  end

  # Called before validation.  sets the ReturnAuthorization number, if the id is nil the ReturnAuthorization number is bogus
  #
  # @param [none]
  # @return [none]
  def set_number
    return set_order_number if self.id
    self.number = (Time.now.to_i).to_s(CHARACTERS_SEED)## fake number for validator
  end

  # sets the order ReturnAuthorization based off constants and the ReturnAuthorization id
  #
  # @param [none]
  # @return [none]
  def set_order_number
    self.number = (NUMBER_SEED + id).to_s(CHARACTERS_SEED)
  end

  # Called after_create.  sets the ReturnAuthorization number
  #
  # @param [none]
  # @return [none]
  def save_order_number
    set_order_number
    save
  end

  ## determines the ReturnAuthorization id from the ReturnAuthorization.number
  #
  # @param [String]  represents the ReturnAuthorization.number
  # @return [Integer] id of the ReturnAuthorization to find
  def self.id_from_number(num)
    num.to_i(CHARACTERS_SEED) - NUMBER_SEED
  end

  ## finds the ReturnAuthorization from the ReturnAuthorizations number.  Is more optimal than the normal rails find by id
  #      because if calculates the ReturnAuthorization's id which is indexed
  #
  # @param [String]  represents the ReturnAuthorization.number
  # @return [ReturnAuthorization]
  def self.find_by_number(num)
    find(id_from_number(num))##  now we can search by id which should be much faster
  end

  # paginated results from the admin return authorization grid
  #
  # @param [Optional params]
  # @return [ Array[ReturnAuthorization] ]
  def self.admin_grid(params = {})

    params[:page] ||= 1
    params[:rows] ||= SETTINGS[:admin_grid_rows]

    grid = includes([:return_items, :order, :user])#paginate({:page => params[:page]})

    grid = grid.where("return_authorizations.number LIKE ?",  "#{params[:number]}%")        if params[:number].present?
    grid = grid.where("orders.order_number LIKE ?",           "#{params[:order_number]}%")  if params[:order_number].present?
    grid = grid.where("return_authorizations.state LIKE ?",      params[:state])               if params[:state].present?
    grid
  end

  private

  # rma validation, if the rma amount is less than the restocking fee why would anyone return an item
  #
  # @param [none]
  # @return [none]
  def ensure_refund_is_larger_than_restocking
    if restocking_fee && restocking_fee >= amount
      self.errors.add(:amount, "The amount must be larger than the restocking fee.")
    end
  end
end
