FactoryGirl.define do
  factory :cart do
    user_id 1
  end

  factory :cart_with_user, :parent => :cart do
    user      { |c| c.association(:user) }
  end

  factory :cart_with_two_5_dollar_items, :parent => :cart do
    shopping_cart_items  { |items| [ items.association(:five_dollar_cart_item),
                                       items.association(:five_dollar_cart_item)
    ]}
  end

  factory :cart_with_two_items, :parent => :cart do
    cart_items  { |items| [ items.association(:five_dollar_cart_item),
                              items.association(:five_dollar_cart_item)
    ]}
  end
end
