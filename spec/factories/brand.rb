FactoryGirl.define do
  factory :brand do
    sequence(:name) { |n| "Brand Name #{n}" }
  end
end
