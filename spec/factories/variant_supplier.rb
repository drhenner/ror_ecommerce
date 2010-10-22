
Factory.define :variant_supplier do |f|
  f.variant_id    1#       { |c| c.association(:variant) }
  f.supplier      { |c| c.association(:supplier) }
  
  f.cost          98.00
  f.total_quantity_supplied  10
  f.min_quantity  10
  f.max_quantity  10000
  f.active        true
end