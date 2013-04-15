# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :newsletter, :class => 'Newsletters' do
    name "MyString"
    autosubscribe false
  end
end
