require 'spec_helper'

describe CartItem do
  context "CartItem" do
    before(:each) do
      @cart_item = FactoryGirl.build(:cart_item)
    end

    it "should be valid with minimum attributes" do
      expect(@cart_item).to be_valid
    end

  end

end

describe Cart, " instance methods" do
  before(:each) do
    @cart_item = FactoryGirl.create(:five_dollar_cart_item)
    @cart_item.item_type_id = ItemType::SHOPPING_CART_ID
  end
  context " price" do
    it 'should have a price of the variant which is 5 dollars' do
      expect(@cart_item.price).to eq 5.0
    end
  end

  context " total" do
    it 'should have a total price of 2 times 5 dollars' do
      @cart_item.stubs(:quantity).returns(2)
      expect(@cart_item.total).to eq 10.0
    end
  end

  context " inactivate!" do
    it 'should not be active' do
      @cart_item.inactivate!
      expect(@cart_item.active).to be false
    end
  end

  context " shopping_cart_item?" do
    it 'should be shopping_cart_item' do
      @cart_item.active = true
      expect(@cart_item.shopping_cart_item?).to be true
    end
    it 'should not be active' do
      @cart_item.active = true
      @cart_item.inactivate!
      expect(@cart_item.shopping_cart_item?).to be false
    end
  end
end

describe Cart, " class methods" do

  #context "#mark_items_purchased(cart, order)" do

  #end
end
