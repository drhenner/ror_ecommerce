# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :accounting_adjustment do
      adjustable_id 1
      adjustable_type "MyString"
      notes "MyString"
      amount "9.99"
    end
end