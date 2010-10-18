
Factory.define :shipment do |f|
  f.number          "34567kjhgf"
  f.order           { |c| c.association(:order) }
  f.address         { |c| c.association(:address) }
  f.shipping_method { |c| c.association(:shipping_method) }
  f.state           "authorized"
  f.shipped_at      Time.now
  f.active          true
end