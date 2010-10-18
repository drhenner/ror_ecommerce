#item_type

Factory.define :cart_item do |u|
  #u.batchable_type  'Order'
  u.item_type     { ItemType.first }
  u.user          { |c| c.association(:user) }
  u.variant       { |c| c.association(:variant) }
  u.cart          { |c| c.association(:cart) }
  u.quantity      2
  u.active        true
end