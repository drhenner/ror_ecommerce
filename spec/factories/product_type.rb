Factory.sequence :product_type_name do |i|
  "Product type Name #{i}"
end

Factory.define :product_type do |u|
  u.name        { Factory.next(:product_type_name) }
  u.active      true
  #u.parent_id
end