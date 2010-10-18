Factory.sequence :name do |i|
  "Product Name #{i}"
end
Factory.sequence :permalink do |i|
  "Product Name #{i}"
end

Factory.define :product do |u|
  u.name              { Factory.next(:name) }
  u.description       'Describe Product'
  u.tax_category      { |c| c.association(:tax_category) }
  u.product_type      { |c| c.association(:product_type) }
  u.prototype         { |c| c.association(:prototype) }
  u.shipping_category { |c| c.association(:shipping_category) }
  u.tax_status        { |c| c.association(:tax_status) }
  u.permalink         { Factory.next(:name) }
  u.available_at      Time.now
  u.deleted_at        nil
  u.featured          true
  u.meta_keywords     ''
  u.meta_description  ''
end