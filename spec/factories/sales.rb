# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sale do
    product { |c| c.association(:product) }
    percent_off "9.99"
    starts_at "2012-08-30 17:09:52"
    ends_at "2017-08-30 17:09:52"
  end
end
