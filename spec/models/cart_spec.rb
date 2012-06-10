require 'spec_helper'

describe Cart, ".sub_total" do
  # shopping_cart_items.inject(0) {|sum, item| item.total + sum}
  
  before(:each) do
    @cart = create(:cart_with_two_5_dollar_items)
  end
  
  it "should calculate subtotal correctly" do
    @cart.sub_total.should == 10.00
  end
end

describe Cart, " instance methods" do
  before(:each) do
    @cart = create(:cart_with_two_5_dollar_items)
  end

  #  items_to_add_or_destroy is exersized within add_items_to_checkout
  #describe Cart, ".items_to_add_or_destroy" do
  #   "this method is tested within add_items_to_checkout method"
  #end
  #  update_shopping_cart is exersized within add_items_to_checkout
  #describe Cart, ".update_shopping_cart(cart_item,customer)" do
  #  pending "test for update_cart(cart_item,customer)"
  #end
  
  context " add_items_to_checkout" do
    
    before(:each) do
      @order = create(:in_progress_order)
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
      @cart.shopping_cart_items.push(create(:cart_item))
      @cart.add_items_to_checkout(@order)
      @order.order_items.size.should == 3     
    end
    
    it 'should remove items not in cart to in_progress orders' do
      @cart.shopping_cart_items.push(create(:cart_item))
      @cart.add_items_to_checkout(@order) ##
      @order.order_items.size.should == 3 
      cart = create(:cart_with_two_5_dollar_items)
      cart.add_items_to_checkout(@order)
      @order.order_items.size.should == 2
    end
  end
  
  context ".save_user(u)" do
    #pending "test for save_user(u)"
    it 'should assign the user to the cart' do
      user = create(:user)
      @cart.save_user(user)
      @cart.user.should == user
    end
  end
  
end

describe Cart, '' do
  
  before(:each) do
    @cart = create(:cart_with_two_items)
  end
  
  context 'mark_items_purchased(order)' do
    it 'should mark cart items as purchased' do
      
      order = create(:order)
      order.stubs(:variant_ids).returns(@cart.cart_items.collect{|ci| ci.variant_id})
      @cart.mark_items_purchased(order)
      @cart.cart_items.each do |ci|
        ci.reload.item_type_id.should == ItemType::PURCHASED_ID
      end
    end
    
    it 'should not mark cart items as purchased if it isnt in the order' do
      
      order = create(:order)
      order.stubs(:variant_ids).returns([])
      @cart.mark_items_purchased(order)
      @cart.cart_items.each do |ci|
        ci.reload.item_type_id.should_not == ItemType::PURCHASED_ID
      end
    end
  end
end

describe Cart, ".add_variant" do
  # need to stub variant.sold_out? and_return(false)
  before(:each) do
    @cart = create(:cart_with_two_5_dollar_items)
    @variant = create(:variant)
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
    @cart.add_variant(@variant.id, nil)
    
    @cart.shopping_cart_items.size.should == cart_item_size
    @cart.saved_cart_items.size.should == 1
  end
end

describe Cart, ".remove_variant" do
  it 'should inactivate variant in cart' do
    @cart = create(:cart_with_two_items)
    variant_ids =  @cart.cart_items.collect {|ci| ci.variant.id }
    @cart.remove_variant(variant_ids.first)
    @cart.cart_items.each do |ci|
      ci.active.should be_false if ci.variant.id == variant_ids.first
    end
  end
end


