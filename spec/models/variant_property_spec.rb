require 'spec_helper'

describe VariantProperty do
  context "Valid VariantProperty" do
    before(:each) do
      @variant_property = Factory.build(:variant_property)
    end
    
    it "should be valid with minimum attributes" do
      @variant_property.should be_valid
    end
  end
  
end
