class ShippingMethod < ActiveRecord::Base
  has_many :shipping_rates
  belongs_to :shipping_zone

  validates  :name,  :presence => true,       :length => { :maximum => 255 }
  validates  :shipping_zone_id,  :presence => true

end
