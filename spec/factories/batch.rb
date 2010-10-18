
Factory.define :batch do |u|
  #u.batchable_type  'Order'
  u.batchable       { |c| c.association(:order) }
  u.name            'Blah'
end