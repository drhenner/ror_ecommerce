Factory.sequence :name do |i|
  "Product type Name #{i}"
end

Factory.define :product_type do |u|
  u.name        { Factory.next(:name) }
  u.active      true
  #u.parent_id   
end