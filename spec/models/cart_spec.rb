require 'spec_helper'

describe Cart, ".sub_total" do
  # shopping_cart_items.inject(0) {|sum, item| item.total + sum}
  
  before(:each) do
    @cart = Factory(:cart_with_two_5_dollar_items)
  end
  
  it "should calculate subtotal correctly" do
    @cart.sub_total.should == 10.00
  end
end

describe Cart, ".add_items_to_checkout" do
  pending "test for add_items_to_checkout"
end

describe Cart, ".items_to_add_or_destroy" do
  pending "test for items_to_add_or_destroy"
end

describe Cart, ".add_variant" do
  pending "test for add_variant"
end

describe Cart, ".remove_variant" do
  pending "test for remove_variant"
end

describe Cart, ".save_user(u)" do
  pending "test for save_user(u)"
end

describe Cart, ".cart_item_ids" do
  pending "test for cart_item_ids"
end

describe Cart, ".update_cart(cart_item,customer)" do
  pending "test for update_cart(cart_item,customer)"
end
