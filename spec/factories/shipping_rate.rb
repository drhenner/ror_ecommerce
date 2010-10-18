
Factory.define :shipping_rate do |f|
  f.rate                  21.08
  f.shipping_method       { |c| c.association(:shipping_method) }
  f.shipping_rate_type    { ShippingRateType.first }
  f.shipping_category     { |c| c.association(:shipping_category) }
  f.minimum_charge        2.95
  f.position              1
  f.active                true
end