
Factory.define :purchase_order_variant do |u|
  u.purchase_order  { |c| c.association(:purchase_order) }
  u.variant         { |c| c.association(:variant) }
  u.quantity        4
  u.cost            33.24
  u.is_received     false
end