
Factory.define :variant do |f|
  f.product       { |c| c.association(:product) }
  f.sku           '345-98765-0987'
  
  f.cost          8.00
  f.deleted_at    nil
  f.master        nil
  f.count_on_hand             10000
  f.count_pending_to_customer 1000
  f.count_pending_from_supplier 900
end