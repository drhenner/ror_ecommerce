Factory.sequence :name do |i|
  "Product Name #{i}"
end
Factory.sequence :permalink do |i|
  "permalink  #{i}"
end

Factory.define :product do |u|
  u.name              { Factory.next(:name) }
  u.description       'Describe Product'
  u.description_markup 'Describe Product'
  u.product_type      { |c| c.association(:product_type) }
  u.prototype         { |c| c.association(:prototype) }
  u.shipping_category { |c| c.association(:shipping_category) }
  u.tax_status        { TaxStatus.first }
  u.permalink         { Factory.next(:permalink) }
  u.available_at      Time.now
  u.deleted_at        nil
  u.featured          true
  u.meta_description  'Describe the variant'
  u.meta_keywords      'Key One, Key Two'
end

Factory.define :product_with_image, :parent => :product do |u|
  valid_file = File.new(File.join(Rails.root, 'spec', 'support', 'rails.png'))
  u.images {
     [
       ActionController::TestUploadedFile.new(valid_file, Mime::Type.new('application/png'))
     ]
  }
end
