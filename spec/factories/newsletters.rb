# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :newsletter do
    name "MyString"
    autosubscribe false
  end
end
