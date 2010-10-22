require 'spec_helper'

describe PhoneType do
  describe "Seed data" do
    
    PhoneType.all.each do |phone_type|
      it "should be valid" do 
        phone_type.should be_valid
      end
    end
    
  end
end