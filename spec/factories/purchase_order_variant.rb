FactoryGirl.define do
  factory :purchase_order_variant do
    purchase_order  { |c| c.association(:purchase_order) }
    variant         { |c| c.association(:variant) }
    quantity        4
    cost            33.24
    is_received     false
  end
end
