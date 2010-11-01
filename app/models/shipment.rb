class Shipment < ActiveRecord::Base
  belongs_to :order, :counter_cache => true
  belongs_to :shipping_method
  belongs_to :address#, :polymorphic => true
  
  has_many   :order_items
  
  before_validation :set_number
  after_create      :save_shipment_number
  
  validates :order_id,            :presence => true
  validates :address_id,          :presence => true
  validates :shipping_method_id,  :presence => true
  
  CHARACTERS_SEED = 20 
  NUMBER_SEED     = 2002002002000
  
  state_machine :initial => 'pending' do
    
    event :prepare do
      transition :to => 'ready_to_ship', :from => 'pending'
    end
    
    event :ship do
      transition :to => 'shipped', :from => 'ready_to_ship'
    end
    before_transition :to => 'shipped', :do => [:set_to_shipped]
    after_transition :to => 'shipped', :do => [:ship_inventory, :mark_order_as_shipped]
  end
  
  def set_to_shipped
    self.shipped_at = Time.zone.now
  end
  
  def has_items?
    order_items.size > 0
  end
  
  def ship_inventory
    order_items.each{ |item| item.variant.subtract_pending_to_customer(1) }
    order_items.each{ |item| item.variant.subtract_count_on_hand(1) }
  end
  
  def mark_order_as_shipped
    order.update_attributes(:shipped => true)
  end
  
  def display_shipped_at(format = I18n.translate('time.formats.us_date'))
    shipped_at ? shipped_at.strftime(format) : 'Not Shipped.'
  end
  
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
  
  def set_number
    return set_shipment_number if self.id
    self.number = (Time.now.to_i).to_s## fake number for friendly_id validator
  end
  
  def set_shipment_number
    self.number = (NUMBER_SEED + id).to_s(CHARACTERS_SEED)
  end
  
  def save_shipment_number
    set_shipment_number
    save
  end
  def shipping_addresses
    order.user.shipping_addresses
  end
  def self.find_fulfillment_shipment(id)
    Shipment.includes([{:order => {:user => :shipping_addresses}} , :address ]).find(id)
  end
  
  def self.id_from_number(num)
    num.to_i(CHARACTERS_SEED) - NUMBER_SEED
  end
  
  def self.find_by_number(num)
    find(id_from_number(num))##  now we can search by id which should be much faster
  end
end
