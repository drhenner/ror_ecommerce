class ShippingMethod < ActiveRecord::Base
  has_many :shipping_rates
  belongs_to :shipping_zone
  
  validates  :name,  :presence => true
  validates  :shipping_zone_id,  :presence => true
  
end
