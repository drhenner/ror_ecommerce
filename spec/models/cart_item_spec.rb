require 'spec_helper'

describe CartItem do
  context "CartItem" do
    before(:each) do
      @cart_item = Factory.build(:cart_item)
    end
    
    it "should be valid with minimum attributes" do
      @cart_item.should be_valid
    end
    
  end
  
end
