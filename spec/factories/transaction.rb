FactoryGirl.define do
  factory :transaction do
    type      'CreditCardPurchase'
    batch     { |c| c.association(:batch) }
  end
end
