# == Schema Information
#
# Table name: purchase_orders
#
#  id                   :integer(4)      not null, primary key
#  supplier_id          :integer(4)      not null
#  invoice_number       :string(255)
#  tracking_number      :string(255)
#  notes                :string(255)
#  state                :string(255)
#  ordered_at           :datetime        not null
#  estimated_arrival_on :date
#  created_at           :datetime
#  updated_at           :datetime
#  total_cost           :decimal(8, 2)   default(0.0), not null
#

class PurchaseOrder < ApplicationRecord
  include AASM
  include TransactionAccountable

  belongs_to :supplier

  has_many  :purchase_order_variants
  has_many  :variants, :through => :purchase_order_variants

  has_many  :batches,             :as => :batchable
  has_many  :transaction_ledgers, :as => :accountable

  validates :invoice_number,  presence: true, length: { maximum: 200 }
  validates :ordered_at,      presence: true
  validates :total_cost,      presence: true
  #validates :is_received,     presence: true

  accepts_nested_attributes_for :purchase_order_variants,
                                :reject_if      => lambda { |attributes| attributes['cost'].blank? && attributes['quantity'].blank? },
                                :allow_destroy  => true

  INCOMPLETE  = 'incomplete'
  PENDING     = 'pending'
  RECEIVED    = 'received'
  STATES      = [PENDING, INCOMPLETE, RECEIVED]

  #state_machine :state, :initial => :pending do
  aasm column: :state do
    state :pending, initial: true
    state :incomplete
    state :received

    #after_transition :on => :complete, :do => [:pay_for_order, :receive_variants]

    event :complete, after: [:pay_for_order, :receive_variants] do
      transitions from: [:pending, :incomplete, :received],  to: :received
    end

    # mark as complete even though variants might not have been receive & payment was not made
    event :mark_as_complete do
      transitions :from => [:pending, :incomplete], to: :received
    end
  end

  # in the admin form this is the method called when the form is submitted, The method sets
  # the PO to complete, pays for the order in the accounting peice and adds the inventory to stock
  #
  # @param [String] value for set_keywords in a products form
  # @return [none]
  def receive_po=(answer)

    if (answer == 'true' || answer == '1') && (state != RECEIVED)
      self.complete!
    end
  end

  # in the admin form this is the method called when the form is created, The method
  # determines if the order has already been received
  #
  # @return [Boolean]
  def receive_po
    (state == RECEIVED)
  end

  # called by state machine after the PO is complete.  adds the inventory to stock
  #
  # @param [none]
  # @return [none]
  def receive_variants
    po_variants = PurchaseOrderVariant.where(:purchase_order_id => self.id)
    po_variants.each do |po_variant|
      po_variant.with_lock do
        po_variant.receive! unless po_variant.is_received?
      end
    end
  end

  # returns "Yes" if the PO has been received, otherwise "No"
  #
  # @param [none]
  # @return [String]  "Yes" or "No"
  def display_received
    receive_po ? 'Yes' : 'No'
  end

  def display_estimated_arrival_on
    estimated_arrival_on? ? I18n.localize(estimated_arrival_on, format: :us_date) : ""
  end

  # returns "the tracking #" if the tracking # exists, otherwise "N/A"
  #
  # @param [none]
  # @return [String]  "Yes" or "No"
  def display_tracking_number
    tracking_number? ? tracking_number : 'N/A'
  end

  # returns "Suppliers name" if the supplier exists, otherwise "N/A"
  #
  # @param [none]
  # @return [String]  "Yes" or "No"
  def supplier_name
    supplier.name rescue 'N/A'
  end

  def receive_order_from_credit
      batch = self.batches.create()
      transaction = ReceivePurchaseOrder.new_expensed(self, total_cost)
      batch.transactions.push(transaction)
      batch.save
  end

  def pay_for_order
    now = Time.zone.now
    if self.batches.empty?
        batch = self.batches.create()
        transaction = ReceivePurchaseOrder.new_direct_payment(self, total_cost, now)
        batch.transactions.push(transaction)
        batch.save
    else # thus we are paying after having received the item from credit
      batch       = batches.first
      transaction = ReceivePurchaseOrder.new_expensed_payment(self, total_cost, now)
      batch.transactions.push(transaction)
      batch.save
    end
  end

  # paginated results from the admin PurchaseOrder grid
  #
  # @param [Optional params]
  # @return [ Array[PurchaseOrder] ]
  def self.admin_grid(params = {})
    grid = includes(:supplier)
    grid = grid.where("suppliers.name LIKE ?",                  "#{params[:supplier_name]}%")   if params[:supplier_name].present?
    grid = grid.where("purchase_orders.invoice_number LIKE ?",  "#{params[:invoice_number]}%")  if params[:invoice_number].present?
    grid = grid.where("purchase_orders.tracking_number LIKE ?", "#{params[:tracking_number]}%") if params[:tracking_number].present?
    grid
  end

  # paginated results from the admin PurchaseOrder grid for PO to receive
  #
  # @param [Optional params]
  # @return [ Array[PurchaseOrder] ]
  def self.receiving_admin_grid(params = {})
    grid = where(['purchase_orders.state != ?', PurchaseOrder::RECEIVED])#.where("suppliers.name = ?", params[:name])
    grid = grid.includes([:supplier, :purchase_order_variants])
    grid = grid.where("suppliers.name LIKE ?",                  "#{params[:supplier_name]}%")   if params[:supplier_name].present?
    grid = grid.where("purchase_orders.invoice_number LIKE ?",  "#{params[:invoice_number]}%")  if params[:invoice_number].present?
    grid = grid.where("purchase_orders.tracking_number LIKE ?", "#{params[:tracking_number]}%") if params[:tracking_number].present?
    grid
  end
end
