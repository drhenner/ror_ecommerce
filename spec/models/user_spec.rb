require 'spec_helper'

describe User do
  context "Valid User" do
    before(:each) do
      @user = Factory.build(:user)
    end
    
    it "should be valid with minimum attributes" do
      @user.should be_valid
    end
    
  end
  
end


describe User, ".name" do
  it "should return the correct name" do
    user = Factory.build(:registered_user)
    #should_receive(:authenticate).with("password").and_return(true)
    user.stub!(:first_name).and_return("Fred")
    user.stub!(:last_name).and_return("Flint")
    user.name.should == "Fred Flint"
  end
end

describe User, '.registered_user?' do
  it "should return false for an unregistered user" do
    user = Factory.build(:user)
    user.registered_user?.should be_false
  end
  it "should return true for a registered user" do
    user = Factory.build(:registered_user)
    user.registered_user?.should be_true
  end
  it "should return true for a user registered_with_credit" do
    user = Factory.build(:registered_user_with_credit)
    user.registered_user?.should be_true
  end
end