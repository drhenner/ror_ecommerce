
Factory.define :shipping_method do |f|
  f.name          "34567kjhgf"
  f.shipping_zone { |c| c.association(:shipping_zone) }
end