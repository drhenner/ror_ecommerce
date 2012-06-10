require 'spec_helper'

describe CartItem do
  context "CartItem" do
    before(:each) do
      @cart_item = build(:cart_item)
    end
    
    it "should be valid with minimum attributes" do
      @cart_item.should be_valid
    end
    
  end
  
end

describe Cart, " instance methods" do
  before(:each) do
    @cart_item = create(:five_dollar_cart_item)
    @cart_item.item_type_id = ItemType::SHOPPING_CART_ID
  end
  context " price" do
    it 'should have a price of the variant which is 5 dollars' do
      @cart_item.price.should == 5.0
    end
  end
  
  context " total" do
    it 'should have a total price of 2 times 5 dollars' do
      @cart_item.stubs(:quantity).returns(2)
      @cart_item.total.should == 10.0
    end
  end
  
  context " inactivate!" do
    it 'should not be active' do
      @cart_item.inactivate!
      @cart_item.active.should == false
    end
  end
  
  context " shopping_cart_item?" do
    it 'should be shopping_cart_item' do
      @cart_item.active = true
      @cart_item.shopping_cart_item?.should == true
    end
    it 'should not be active' do
      @cart_item.active = true
      @cart_item.inactivate!
      @cart_item.shopping_cart_item?.should == false
    end
  end
end

describe Cart, " class methods" do
  
  #context "#mark_items_purchased(cart, order)" do
    
  #end
end
