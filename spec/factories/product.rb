FactoryGirl.define do
  factory :product do
    sequence(:name)      { |i| "Product Name #{i}" }
    description          'Describe Product'
    description_markup   'Describe Product'
    brand                { |c| c.association(:brand) }
    product_type         { |c| c.association(:product_type) }
    prototype            { |c| c.association(:prototype) }
    shipping_category    { |c| c.association(:shipping_category) }
    sequence(:permalink) { |i| "permalink  #{i}" }
    available_at         Time.now
    deleted_at           nil
    featured             true
    meta_description     'Describe the variant'
    meta_keywords        'Key One, Key Two'
  end

  factory :product_with_image, :parent => :product do
    valid_file = File.new(File.join(Rails.root, 'spec', 'support', 'rails.png'))
    images {
      [
        ActionController::TestUploadedFile.new(valid_file, Mime::Type.new('application/png'))
      ]
    }
  end
end
