require 'spec_helper'

describe UserRole do
  
  describe "valid UserRole model" do 
    
    it "should be valid" do
      @user_role = FactoryGirl.build(:user_role)
      @user_role.should be_valid
    end
    
  end
end
