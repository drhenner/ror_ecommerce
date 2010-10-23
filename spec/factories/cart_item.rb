
Factory.define :cart_item_without_variant, :class => CartItem do |ci|
  #factory :cart_item do
    ci.item_type_id     ItemType::SHOPPING_CART_ID#{ ItemType.first }
    #ci.user          { |c| c.association(:user) }
    ci.cart          { |c| c.association(:cart) }
    ci.quantity      1
    ci.active        true
  #end

end

Factory.define :cart_item do |ci|
  #factory :cart_item do
    ci.item_type_id     ItemType::SHOPPING_CART_ID#{ ItemType.first }
    #ci.user          { |c| c.association(:user) }
    ci.variant       { |c| c.association(:variant) }
    ci.cart          { |c| c.association(:cart) }
    ci.quantity      1
    ci.active        true
  #end

end

Factory.define :five_dollar_cart_item, :parent => :cart_item do |ci|
  ci.variant       { |c| c.association(:five_dollar_variant) }
  ci.item_type_id     ItemType::SHOPPING_CART_ID#{ ItemType.first }
  ci.active        true
end
