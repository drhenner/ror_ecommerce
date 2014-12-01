require 'spec_helper'

describe ShippingCategory do
  context "Valid ShippingCategory" do
    before(:each) do
      @shipping_category = FactoryGirl.build(:shipping_category)
    end

    it "should be valid with minimum attributes" do
      expect(@shipping_category).to be_valid
    end
  end

end
