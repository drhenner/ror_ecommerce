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


#def add_items_to_checkout(order)
#  if order.in_progress?
#    items = shopping_cart_items.inject({}) {|h, item| h[item.variant_id] = item.quantity; h}
#    items_to_add_or_destroy(items, order.order_items)
#    
#  end
#end
#
#def items_to_add_or_destroy(items_in_cart, order_items)
#  items = order_items.inject({}) {|h, item| h[item.variant_id].nil? ? h[item.variant_id] = [item.id]  : h[item.variant_id] << item.id; h}
#  items.each_pair do |variant_id, array_of_order_items|
#    if items_in_cart[variant_id].nil?
#      # these items arent in the cart...  delete them
#      OrderItem.destroy_all("id IN (?)", array_of_order_items)
#    elsif items_in_cart[variant_id] > array_of_order_items.size ## the number in the cart is larger than the amount in order_items
#      ###  add more to the cart
#      variant = Variant.find(variant_id)
#      order.add_items( variant , (items_in_cart[k] - array_of_order_items.size))
#    elsif items_in_cart[variant_id] < array_of_order_items.size ## the number in the cart is smaller than the amount in order_items
#      #remove items in cart
#      qty_to_remove = array_of_order_items.size - items_in_cart[variant_id]  
#      
#      array_of_order_items.each_with_index do |item, i|
#        OrderItem.destroy(item)
#        break if i+1 == qty_to_remove
#      end
#    end
#  end
#  
#end



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
