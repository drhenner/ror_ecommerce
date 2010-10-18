
Factory.define :image do |u|
  #u.batchable_type  'Order'
  u.batchable       { |c| c.association(:product) }
  u.caption         'Caption blah.'
  u.position        1
end