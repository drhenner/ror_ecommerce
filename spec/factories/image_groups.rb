# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :image_group do
    name "MyString"
    product { |c| c.association(:product) }
  end
end
