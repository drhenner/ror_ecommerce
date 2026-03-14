FactoryBot.define do

  factory :cart_item do |ci|
    item_type_id { ItemType::SHOPPING_CART_ID }
    variant       { |c| c.association(:variant) }
    cart          { |c| c.association(:cart) }
    quantity { 1 }
    active { true }
  end

  factory :five_dollar_cart_item, :parent => :cart_item do |ci|
    variant       { |c| c.association(:five_dollar_variant) }
    item_type_id { ItemType::SHOPPING_CART_ID }
    active { true }
  end
end
