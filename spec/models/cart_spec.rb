require 'spec_helper'

describe Cart, ".sub_total" do
  # shopping_cart_items.inject(0) {|sum, item| item.total + sum}

  before(:each) do
    @cart = FactoryGirl.create(:cart_with_two_5_dollar_items)
  end

  it "should calculate subtotal correctly" do
    expect(@cart.sub_total).to eq 10.00
  end

  it "should give the number of cart items" do
    expect(@cart.number_of_shopping_cart_items).to eq 2
  end

  it "should give the number of cart items" do
    variant = FactoryGirl.create(:variant)
    @cart.add_variant(variant.id, @cart.user, 2)
    expect(@cart.number_of_shopping_cart_items).to eq 4
  end
end

describe Cart, " instance methods" do
  before(:each) do
    @cart = FactoryGirl.create(:cart_with_two_5_dollar_items)
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
      @order = FactoryGirl.create(:in_progress_order)
    end

    it 'should add item to in_progress orders' do
      @cart.add_items_to_checkout(@order)
      expect(@order.order_items.size).to eq 2
    end

    it 'should keep items already in order to in_progress orders' do
      @cart.add_items_to_checkout(@order)
      @cart.add_items_to_checkout(@order)
      expect(@order.order_items.size).to eq 2
    end

    it 'should add only needed items already in order to in_progress orders' do
      @cart.add_items_to_checkout(@order)
      @cart.shopping_cart_items.push(create(:cart_item))
      @cart.add_items_to_checkout(@order)
      expect(@order.order_items.size).to eq 3
    end

    it 'should remove items not in cart to in_progress orders' do
      @cart.shopping_cart_items.push(create(:cart_item))
      @cart.add_items_to_checkout(@order) ##
      expect(@order.order_items.size).to eq 3
      cart = FactoryGirl.create(:cart_with_two_5_dollar_items)
      cart.add_items_to_checkout(@order)
      expect(@order.order_items.size).to eq 2
    end
  end

  context ".save_user(u)" do
    #pending "test for save_user(u)"
    it 'should assign the user to the cart' do
      user = FactoryGirl.create(:user)
      @cart.save_user(user)
      expect(@cart.user).to eq user
    end
  end

end

describe Cart, '' do

  before(:each) do
    @cart = FactoryGirl.create(:cart_with_two_items)
  end

  context 'mark_items_purchased(order)' do
    it 'should mark cart items as purchased' do

      order = FactoryGirl.create(:order)
      order.stubs(:variant_ids).returns(@cart.cart_items.collect{|ci| ci.variant_id})
      @cart.mark_items_purchased(order)
      @cart.cart_items.each do |ci|
        expect(ci.reload.item_type_id).to eq ItemType::PURCHASED_ID
      end
    end

    it 'should not mark cart items as purchased if it isnt in the order' do

      order = FactoryGirl.create(:order)
      order.stubs(:variant_ids).returns([])
      @cart.mark_items_purchased(order)
      @cart.cart_items.each do |ci|
        expect(ci.reload.item_type_id).not_to eq ItemType::PURCHASED_ID
      end
    end
  end
end

describe Cart, ".add_variant" do
  # need to stub variant.sold_out? and_return(false)
  before(:each) do
    @cart = FactoryGirl.create(:cart_with_two_5_dollar_items)
    @variant = FactoryGirl.create(:variant)
  end

  it 'should add variant to cart' do
    Variant.any_instance.stubs(:sold_out?).returns(false)
    cart_item_size = @cart.shopping_cart_items.size
    @cart.add_variant(@variant.id, @cart.user)
    expect(@cart.shopping_cart_items.size).to eq cart_item_size + 1
  end

  it 'should add quantity of variant to cart' do
    Variant.any_instance.stubs(:sold_out?).returns(false)
    cart_item_size = @cart.shopping_cart_items.size
    @cart.add_variant(@variant.id, @cart.user)
    @cart.add_variant(@variant.id, @cart.user)
    @cart.cart_items.each do |item|
      #puts "#{item.variant_id} : #{@variant.id}  (#{item.quantity})"
      expect(item.quantity).to eq 2 if item.variant_id == @variant.id
    end

    expect(@cart.shopping_cart_items.size).to eq cart_item_size + 1
  end

  it 'should add quantity of variant to saved_cart_items if out of stock' do
    Variant.any_instance.stubs(:sold_out?).returns(true)
    cart_item_size = @cart.shopping_cart_items.size
    @cart.add_variant(@variant.id, nil)

    expect(@cart.shopping_cart_items.size).to eq cart_item_size
    expect(@cart.saved_cart_items.size).to eq 1
  end
end

describe Cart, ".remove_variant" do
  it 'should inactivate variant in cart' do
    @cart = FactoryGirl.create(:cart_with_two_items)
    variant_ids =  @cart.cart_items.collect {|ci| ci.variant.id }
    @cart.remove_variant(variant_ids.first)
    @cart.cart_items.each do |ci|
      expect(ci.active).to( be false ) if ci.variant.id == variant_ids.first
    end
  end
end

describe  ".merge_with_previous_cart! " do
  before(:each) do
    @user     = FactoryGirl.create(:user)
    @variant1 = FactoryGirl.create(:variant, price: 1.00)
    @variant2 = FactoryGirl.create(:variant, price: 5.00)
    @variant3 = FactoryGirl.create(:variant, price: 30.00)
    @cart       = FactoryGirl.create(:cart, user: @user)
    @cart_item  = FactoryGirl.create(:cart_item, cart: @cart, user: @user, variant: @variant1, quantity: 2)
  end

  context 'with each cart having one item' do
    it 'should add items from previous cart' do
      previous_cart = FactoryGirl.create(:cart, user: @user)
      cart_item2    = FactoryGirl.create(:cart_item, cart: previous_cart, user: @user, variant: @variant2)
      @cart.merge_with_previous_cart!
      @cart.reload
      expect(@cart.cart_items.map(&:variant_id).include?(@variant1.id)).to be true
      expect(@cart.cart_items.map(&:variant_id).include?(@variant2.id)).to be true
    end
  end

  context 'with each cart having the same' do
    it 'should add items from previous cart' do
      previous_cart = FactoryGirl.create(:cart, user: @user)
      cart_item2    = FactoryGirl.create(:cart_item, cart: previous_cart, user: @user, variant: @variant1, quantity: 1)
      @cart.merge_with_previous_cart!
      @cart.reload
      expect(@cart.cart_items.map(&:variant_id).include?(@variant1.id)).to be true
      expect(@cart.cart_items.size).to eq 1
      expect(@cart.cart_items.first.quantity).to eq 2
    end
  end
end

describe Cart, ".shopping_cart_items_equal_order_items?" do
  before(:each) do
    @order = FactoryGirl.create(:order)
    @cart = FactoryGirl.create(:cart)
  end

  context 'when cart items are equal orders' do
    before(:each) do
      variant = FactoryGirl.create(:variant)
      @cart.add_variant(variant.id, @cart.user, 2)
      @order.add_items(variant, 2)
    end

    it 'shold return true' do
      expect(@cart.shopping_cart_items_equal_order_items?(@order)).to eq true
    end
  end

  context 'when amount is not equal' do
    before(:each) do
      variant = FactoryGirl.create(:variant)
      @cart.add_variant(variant.id, @cart.user, 2)
    end

    it 'should return false' do
      expect(@cart.shopping_cart_items_equal_order_items?(@order)).to eq false
    end
  end

  context 'when variants are not equal' do
    before(:each) do
      variant_1 = FactoryGirl.create(:variant)
      variant_2 = FactoryGirl.create(:variant)
      @cart.add_variant(variant_1.id, @cart.user, 2)
      @order.add_items(variant_2, 2)
    end

    it 'should return false' do
      expect(@cart.shopping_cart_items_equal_order_items?(@order)).to eq false
    end
  end

  context 'when variant quantity is not equal, but total amount is equal' do
    before(:each) do
      variant_1 = FactoryGirl.create(:variant)
      variant_2 = FactoryGirl.create(:variant)
      @cart.add_variant(variant_1.id, @cart.user, 1)
      @order.add_items(variant_1, 2)
      @cart.add_variant(variant_2.id, @cart.user, 2)
      @order.add_items(variant_2, 1)
    end

    it 'should return false' do
      expect(@cart.shopping_cart_items_equal_order_items?(@order)).to eq false
    end
  end
end
