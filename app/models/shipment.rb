# == Schema Information
#
# Table name: shipments
#
#  id                 :integer(4)      not null, primary key
#  order_id           :integer(4)
#  shipping_method_id :integer(4)      not null
#  address_id         :integer(4)      not null
#  tracking           :string(255)
#  number             :string(255)     not null
#  state              :string(255)     not null
#  shipped_at         :datetime
#  active             :boolean(1)      default(TRUE), not null
#  created_at         :datetime
#  updated_at         :datetime
#

class Shipment < ApplicationRecord
  include AASM

  belongs_to :order, :counter_cache => true
  belongs_to :shipping_method
  belongs_to :address#, :polymorphic => true

  has_many   :order_items

  before_validation :set_number
  after_create      :save_shipment_number

  validates :order_id,            presence: true
  validates :address_id,          presence: true
  validates :shipping_method_id,  presence: true

  CHARACTERS_SEED = 20
  NUMBER_SEED     = 2002002002000

  aasm column: :state do
    state :pending, initial: true
    state :ready_to_ship
    state :shipped

    event :prepare do
      transitions to: :ready_to_ship, from: :pending
    end

    event :ship, before: :set_to_shipped, after: [:ship_inventory, :mark_order_as_shipped] do
      transitions to: :shipped, from: :ready_to_ship
    end

  end

  # sets the shipped at time to the current time
  #
  # @param [none]
  # @return [ none ]
  def set_to_shipped
    self.shipped_at = Time.zone.now
  end

  # determines if shipment has order items
  #
  # @param [none]
  # @return [ Boolean ]
  def has_items?
    order_items.size > 0
  end

  # when the order has been shipped
  #   the inventory must be updated
  def ship_inventory
    order_items.each do |item|
      item.variant.subtract_pending_to_customer(1)
      item.variant.subtract_count_on_hand(1)
    end
  end

  # mark the order as shipped when the item ships
  #
  # @param [none]
  # @return [ none ]
  def mark_order_as_shipped
    order.update_attributes(:shipped => true)
  end

  # when the order has been shipped the inventory must be updated
  #
  # @param [Optional String] format of the date string returned
  # @return [ String ]
  def display_shipped_at(format = I18n.translate('time.formats.us_date'))
    shipped_at ? shipped_at.strftime(format) : 'Not Shipped.'
  end

  # called when creating the shipment >>>
  # * Creates a shipment object
  # * Adds all the order items to the shipment
  # * transitions the shipment state to ready_to_ship
  #
  # @param [Order]
  # @return [ none ]
  def self.create_shipments_with_items(order)
    order.order_items.group_by(&:shipping_method_id).each do |shipping_method_id, order_items|
      shipment = Shipment.new(:shipping_method_id => shipping_method_id,
                              :address_id         => order.ship_address_id,
                              :order_id           => order.id
                              )
      order_items.each do |item|
        shipment.order_items.push(item)
      end
      shipment.prepare!
    end
  end

  # Addresses that the user has to ship to
  #
  # @param [none]
  # @return [ Array [Address] ] all user addresses
  def shipping_addresses
    order.user.shipping_addresses
  end

  ## finds the Shipment in the admin area (includes to prevent N + 1 queries)
  #
  # @param [Integer]  shipment.id
  # @return [Shipment]
  def self.find_fulfillment_shipment(id)
    includes([{:order => {:user => :shipping_addresses}} , :address ]).find(id)
  end

  ## determines the shipment id from the shipment.number
  #
  # @param [String]  represents the shipment.number
  # @return [Integer] id of the shipment to find
  def self.id_from_number(num)
    num.to_i(CHARACTERS_SEED) - NUMBER_SEED
  end

  ## finds the Shipment from the shipments number.  Is more optimal than the normal rails find by id
  #      because if calculates the shipment's id which is indexed
  #
  # @param [String]  represents the shipment.number
  # @return [Shipment]
  def self.find_by_number(num)
    find(id_from_number(num))##  now we can search by id which should be much faster
  end

  private

  # Called before validation.  sets the shipment number, if the id is nil the shipment number is bogus
  #
  # @param none
  # @return [none]
  def set_number
    return set_shipment_number if self.id
    self.number = (Time.now.to_i).to_s## fake number for validator
  end

  # sets the order shipment based off constants and the shipment id
  #
  # @param none
  # @return [none]
  def set_shipment_number
    self.number = (NUMBER_SEED + id).to_s(CHARACTERS_SEED)
  end

  # Called after_create.  sets the shipment number
  #
  # @param none
  # @return [none]
  def save_shipment_number
    set_shipment_number
    save
  end
end
