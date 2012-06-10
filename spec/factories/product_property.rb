FactoryGirl.define do
  factory :product_property do
    product         { |c| c.association(:product) }
    property        { |c| c.association(:property) }
    description     'Red, Blue and Orange Flavors'
    #position       1
  end
end
