# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :inventory do
    count_on_hand             10000
    count_pending_to_customer 1000
    count_pending_from_supplier 900
  end
end
