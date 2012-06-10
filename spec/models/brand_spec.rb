require 'spec_helper'

describe Brand do
  context " Brand" do
    before(:each) do
      @brand = build(:brand)
    end
    
    it "should be valid with minimum attribues" do
      @brand.should be_valid
    end
    
  end
  
end
