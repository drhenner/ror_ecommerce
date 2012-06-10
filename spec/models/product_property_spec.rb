require 'spec_helper'

describe ProductProperty do
  context "Valid ProductProperty" do
    before(:each) do
      @product_property = build(:product_property)
    end
    
    it "should be valid with minimum attributes" do
      @product_property.should be_valid
    end
  end
  
end
