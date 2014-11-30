require 'spec_helper'

describe UserRole do

  describe "valid UserRole model" do

    it "should be valid" do
      @user_role = FactoryGirl.build(:user_role)
      expect(@user_role).to be_valid
    end

  end
end
