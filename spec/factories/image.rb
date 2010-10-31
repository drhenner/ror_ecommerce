
Factory.define :image do |u|
  #u.batchable_type  'Order'
  u.imageable       { |c| c.association(:product) }
  u.caption         'Caption blah.'
  u.position        1
end