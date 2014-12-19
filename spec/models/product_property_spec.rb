require 'spec_helper'

describe ProductProperty do
  context "Valid ProductProperty" do
    before(:each) do
      @product_property = FactoryGirl.build(:product_property)
    end

    it "should be valid with minimum attributes" do
      expect(@product_property).to be_valid
    end
  end

end
