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
    user.stubs(:first_name).returns("Fred")
    user.stubs(:last_name).returns("Flint")
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

describe User, "instance methods" do
  context ".admin?" do
    it 'ahould be an admin' do
      user = Factory(:admin_user)
      user.admin?.should be_true
    end
  
    it 'ahould be an admin' do
      user = Factory(:super_admin_user)
      user.admin?.should be_true
    end
    
    it 'ahould not be an admin' do
      user = Factory(:user)
      user.admin?.should be_false
    end
  end
end

describe User, "instance methods" do
  before(:each) do
    @user = Factory(:user)
  end
  
  context ".active?" do
    it 'should not be active' do
      @user.state = 'canceled'
      @user.active?.should be_false
      @user.state = 'inactive'
      @user.active?.should be_false
    end
    
    it 'should be active' do
      @user.state = 'unregistered'
      @user.active?.should be_true
      @user.state = 'registered'
      @user.active?.should be_true
    end
  end

  context ".role?(role_name)" do
    it 'should be active' do
      @user.state = 'unregistered'
      @user.active?.should be_true
      @user.state = 'registered'
      @user.active?.should be_true
    end
  end

  context ".display_active" do
    it 'should not be active' do
      @user.state = 'canceled'
      @user.display_active.should == 'false'
    end
    
    it 'should be active' do
      @user.state = 'unregistered'
      @user.display_active.should == 'true'
    end
  end

  context ".current_cart" do
    pending "test for current_cart"
  end

  context ".might_be_interested_in_these_products" do
    pending "test for might_be_interested_in_these_products"
  end

  context ".billing_address" do
    pending "test for billing_address"
  end

  context ".registered_user?" do
    pending "test for registered_user?"
  end

  context ".sanitize_data" do
    pending "test for sanitize_data"
  end

  context ".deliver_activation_instructions!" do
    pending "test for deliver_activation_instructions!"
  end

  context ".email_address_with_name" do
    pending "test for email_address_with_name"
  end

  context ".get_cim_profile" do
    pending "test for get_cim_profile"
  end

  context ".merchant_description" do
    pending "test for merchant_description"
  end

  context "#admin_grid(params = {})" do
    pending "test for admin_grid"
  end

  context ".password_required?" do
    pending "test for password_required"
  end

  context ".create_cim_profile" do
    pending "test for create_cim_profile"
  end

  context ".before_validation_on_create" do
    pending "test for before_validation_on_create"
  end

  context ".user_profile" do
    pending "test for user_profile"
  end
end