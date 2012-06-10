FactoryGirl.define do
  factory :inventory do
    count_on_hand             10000
    count_pending_to_customer 1000
    count_pending_from_supplier 900
  end
end
