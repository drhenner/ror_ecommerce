require 'spec_helper'

describe Phone do
  context "Phone" do
    before(:each) do
      @phone = build(:phone)
    end
    
    it "should be valid with minimum attributes" do
      @phone.should be_valid
    end
    
  end
  
end

describe Phone, "#save_default_phone(object, params)" do
  pending "test for save_default_phone(object, params)"
end