
Factory.define :product_property do |u|
  u.product         { |c| c.association(:product) }
  u.property        { |c| c.association(:property) }
  u.description     'Red, Blue and Orange Flavors'
  #u.position       1
end