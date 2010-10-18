Factory.sequence :name do |i|
  "An item type Name #{i}"
end

Factory.define :item_type do |u|
  u.name  { Factory.next(:name) }
end

