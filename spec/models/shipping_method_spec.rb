require 'spec_helper'

describe ShippingMethod do
  context "Valid ShippingMethod" do
    before(:each) do
      @shipping_method = FactoryGirl.build(:shipping_method)
    end

    it "should be valid with minimum attributes" do
      expect(@shipping_method).to be_valid
    end
  end

end
