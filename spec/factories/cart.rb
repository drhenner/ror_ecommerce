
Factory.define :cart do |c|
  #factory :cart do
    c.user_id     1# { |c| c.association(:user) }
  #end
end

Factory.define :cart_with_user, :parent => :cart do |c|
  #factory :cart do
    c.user      { |c| c.association(:user) }
  #end 
end
Factory.define :cart_with_two_5_dollar_items, :parent => :cart do |c|
  c.shopping_cart_items  { |items| [ items.association(:five_dollar_cart_item), 
                            items.association(:five_dollar_cart_item)
                        ]}
end

Factory.define :cart_with_two_items, :parent => :cart do |c|
  c.cart_items  { |items| [ items.association(:five_dollar_cart_item), 
                            items.association(:five_dollar_cart_item)
                        ]}
end