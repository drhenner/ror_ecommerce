FactoryGirl.define do
  factory :product_type do
    sequence(:name)        { |i| "Product type Name #{i}" }
    active      true
    #parent_id
  end
end
