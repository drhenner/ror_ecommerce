class ShippingRate < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  belongs_to :shipping_method
  belongs_to :shipping_rate_type
  
  belongs_to  :shipping_category
  has_many    :products
  
  validates  :rate,                   :presence => true, :numericality => true
  
  validates  :shipping_method_id,     :presence => true
  validates  :shipping_rate_type_id,  :presence => true
  validates  :shipping_category_id,   :presence => true
  
  scope :with_these_shipping_methods, lambda { |shipping_rate_ids, shipping_method_ids|
          {:conditions => ['shipping_rates.id IN (?) AND 
                            shipping_rates.shipping_method_id IN (?)',shipping_rate_ids, shipping_method_ids]}
        }
  
  def individual?
    shipping_rate_type_id == ShippingRateType::INDIVIDUAL_ID
  end
  
  def name
    [shipping_method.name, shipping_method.shipping_zone.name, sub_name].join(', ')
  end
  
  def sub_name
    '(' + [shipping_rate_type.name, rate ].join(' - ') + ')'
  end
  
  def name_with_rate
    [shipping_method.name, number_to_currency(rate)].join(' - ')
  end
  
  def self.shipping_rates_with_these_shipping_methods(shipping_rate_ids , shipping_method_ids)
    find.where(['shipping_rates.shipping_method_id IN (?)',shipping_method_ids])
  end
end
