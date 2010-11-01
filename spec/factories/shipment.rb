
Factory.define :shipment do |f|
  #f.number          "34567kjhgf"
  f.order           { |c| c.association(:order) }
  f.address         { |c| c.association(:address) }
  #f.address_id      1 
  f.shipping_method { |c| c.association(:shipping_method) }
  f.state           "ready_to_ship"
  f.shipped_at      nil
  f.active          true
end