FactoryGirl.define do
  factory :shipping_method do
    name          "34567kjhgf"
    shipping_zone { ShippingZone.first }
  end
end
