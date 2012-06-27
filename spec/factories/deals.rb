# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :deal do
      buy_quantity  3
      get_percentage 50
      deal_type     { DealType.first }
      product_type  { |c| c.association(:product_type) }
      get_amount   nil
    end
end

