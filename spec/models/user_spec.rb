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

describe User, ".active?" do
  pending "test for active?"
end

describe User, ".role?(role_name)" do
  pending "test for role?(role_name)"
end

describe User, ".admin?" do
  pending "test for admin?"
end

describe User, ".super_admin?" do
  pending "test for super_admin?"
end

describe User, ".display_active" do
  pending "test for display_active"
end

describe User, ".current_cart" do
  pending "test for current_cart"
end

describe User, ".might_be_interested_in_these_products" do
  pending "test for might_be_interested_in_these_products"
end

describe User, ".billing_address" do
  pending "test for billing_address"
end

describe User, ".registered_user?" do
  pending "test for registered_user?"
end

describe User, ".sanitize_data" do
  pending "test for sanitize_data"
end

describe User, ".deliver_activation_instructions!" do
  pending "test for deliver_activation_instructions!"
end

describe User, ".email_address_with_name" do
  pending "test for email_address_with_name"
end

describe User, ".get_cim_profile" do
  pending "test for get_cim_profile"
end

describe User, ".merchant_description" do
  pending "test for merchant_description"
end

describe User, "#admin_grid(params = {})" do
  pending "test for admin_grid"
end

describe User, ".password_required?" do
  pending "test for password_required"
end

describe User, ".create_cim_profile" do
  pending "test for create_cim_profile"
end

describe User, ".before_validation_on_create" do
  pending "test for before_validation_on_create"
end

describe User, ".user_profile" do
  pending "test for user_profile"
end
