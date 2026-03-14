# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :newsletter do
    name "MyString"
    autosubscribe false
  end
end
