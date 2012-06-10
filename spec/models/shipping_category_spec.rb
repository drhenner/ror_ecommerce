require 'spec_helper'

describe ShippingCategory do
  context "Valid ShippingCategory" do
    before(:each) do
      @shipping_category = build(:shipping_category)
    end
    
    it "should be valid with minimum attributes" do
      @shipping_category.should be_valid
    end
  end
  
end
