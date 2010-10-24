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

describe Cart, " instance methods" do
  before(:each) do
    @cart = Factory(:cart_with_two_5_dollar_items)
  end
  context " add_items_to_checkout" do
    
    before(:each) do
      @order = Factory(:in_progress_order)
    end
    
    it 'should add item to in_progress orders' do
      @cart.add_items_to_checkout(@order)
      @order.order_items.size.should == 2      
    end
    
    it 'should keep items already in order to in_progress orders' do
      @cart.add_items_to_checkout(@order)
      @cart.add_items_to_checkout(@order)
      @order.order_items.size.should == 2
    end
    
    it 'should add only needed items already in order to in_progress orders' do
      @cart.add_items_to_checkout(@order)
      @cart.shopping_cart_items.push(Factory(:cart_item))
      @cart.add_items_to_checkout(@order)
      @order.order_items.size.should == 3     
    end
    
    it 'should remove items not in cart to in_progress orders' do
      @cart.shopping_cart_items.push(Factory(:cart_item))
      @cart.add_items_to_checkout(@order) ##
      @order.order_items.size.should == 3 
      cart = Factory(:cart_with_two_5_dollar_items)
      cart.add_items_to_checkout(@order)
      @order.order_items.size.should == 2
    end
  end
end

describe Cart, ".items_to_add_or_destroy" do
   "this method is tested within add_items_to_checkout method"
end

describe Cart, ".add_variant" do
  # need to stub variant.sold_out? and_return(false)
  before(:each) do
    @cart = Factory(:cart_with_two_5_dollar_items)
    @variant = Factory(:variant)
  end
  
  it 'should add variant to cart' do
    Variant.any_instance.stubs(:sold_out?).returns(false)
    cart_item_size = @cart.shopping_cart_items.size
    @cart.add_variant(@variant.id, @cart.user)
    @cart.shopping_cart_items.size.should == cart_item_size + 1
  end
  
  it 'should add quantity of variant to cart' do
    Variant.any_instance.stubs(:sold_out?).returns(false)
    cart_item_size = @cart.shopping_cart_items.size
    @cart.add_variant(@variant.id, @cart.user)
    @cart.add_variant(@variant.id, @cart.user)
    @cart.cart_items.each do |item|
      #puts "#{item.variant_id} : #{@variant.id}  (#{item.quantity})"
      item.quantity.should == 2 if item.variant_id == @variant.id
    end
    
    @cart.shopping_cart_items.size.should == cart_item_size + 1
  end
  
  it 'should add quantity of variant to saved_cart_items if out of stock' do
    Variant.any_instance.stubs(:sold_out?).returns(true)
    cart_item_size = @cart.shopping_cart_items.size
    @cart.add_variant(@variant.id, @cart.user)
    
    @cart.shopping_cart_items.size.should == cart_item_size
    @cart.saved_cart_items.size.should == 1
  end
end


#def remove_variant(variant_id)
#  ci = cart_items.find_by_variant_id(variant_id)
#  ci.inactivate!
#  return ci
#end

describe Cart, ".remove_variant" do
  it 'should inactivate variant in cart' do
    @cart = Factory(:cart_with_two_items)
    variant_ids =  @cart.cart_items.collect {|ci| ci.variant.id }
    @cart.remove_variant(variant_ids.first)
    @cart.cart_items.each do |ci|
      ci.active.should be_false if ci.variant.id == variant_ids.first
    end
  end
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
