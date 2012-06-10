FactoryGirl.define do
  factory :store_credit do
    amount          0.0
    user            { |c| c.association(:user) }
  end
end
