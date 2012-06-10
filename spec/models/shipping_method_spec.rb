require 'spec_helper'

describe ShippingMethod do
  context "Valid ShippingMethod" do
    before(:each) do
      @shipping_method = build(:shipping_method)
    end
    
    it "should be valid with minimum attributes" do
      @shipping_method.should be_valid
    end
  end
  
end
