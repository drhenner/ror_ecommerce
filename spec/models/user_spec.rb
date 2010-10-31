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
    it 'should use the last cart' do
      cart1 = @user.carts.new
      cart1.save
      cart2 = @user.carts.new
      cart2.save
      @user.current_cart.should == cart2
    end
  end

  context ".might_be_interested_in_these_products" do
    it 'should find products' do
      product = Factory(:product)
      @user.might_be_interested_in_these_products.include?(product).should be_true
    end
    
    #pending "add your specific find products method here"
  end

  context ".billing_address" do
    # default_billing_address ? default_billing_address : default_shipping_address
    it 'should return nil if you dont have an address' do
      #add = Factory(:address, :addressable => @user, :default => true)
      @user.billing_address.should be_nil
    end
    
    it 'should use your shipping address if you dont have a default billing address' do
      add = Factory(:address, :addressable => @user, :default => true)
      @user.billing_address.should == add
    end
    
    it 'should use your default billing address if you have one available' do
      add = Factory(:address, :addressable => @user, :default => true)
      bill_add = Factory(:address, :addressable => @user, :billing_default => true)
      @user.billing_address.should == bill_add
    end
    
    it 'should return the first address if not defaults are set' do
      #add = Factory(:address, :addressable => @user, :default => true)
      add = Factory(:address, :addressable => @user)
      @user.billing_address.should == add
    end
  end

  context ".shipping_address" do
    # default_billing_address ? default_billing_address : default_shipping_address
    it 'should return nil if you dont have an address' do
      #add = Factory(:address, :addressable => @user, :default => true)
      @user.shipping_address.should be_nil
    end
    
    it 'should use your default shipping address if you have one available' do
      add = Factory(:address, :addressable => @user, :default => true)
      bill_add = Factory(:address, :addressable => @user, :billing_default => true)
      @user.shipping_address.should == add
    end
    
    it 'should return the first address if not defaults are set' do
      #add = Factory(:address, :addressable => @user, :default => true)
      add = Factory(:address, :addressable => @user)
      @user.shipping_address.should == add
    end
  end
  
  context ".registered_user?" do
    # registered? || registered_with_credit?
    it 'should be true for a registered user' do
      @user.register!
      @user.registered_user?.should be_true
    end
    it 'should be true for a registered_with_credit user' do
      @user.state = 'registered_with_credit'
      @user.registered_user?.should be_true
    end

    it 'should not be a registered user' do
      @user.state = 'active'
      @user.registered_user?.should be_false
    end

    it 'should not be a registered user' do
      @user.state = 'canceled'
      @user.registered_user?.should be_false
    end
  end

  context ".sanitize_data" do
    it "should  sanitize data" do
      @user.email           = ' bad@email.com '
      @user.first_name      = ' bAd NamE '
      @user.last_name       = ' lastnamE '
      @user.account         = nil
      
      @user.sanitize_data
      
      @user.email.should        == 'bad@email.com'
      @user.first_name.should   == 'Bad name'
      @user.last_name.should    == 'Lastname'
      @user.account.should_not  be_nil
    end
  end

  context ".deliver_activation_instructions!" do
    #pending "test for deliver_activation_instructions!"
    #Notifier.signup_notification(self).deliver
    # @order_item.order.expects(:calculate_totals).once
    it 'should call signup_notification and deliver' do
      sign_up_mock = mock()
      #Notifier.stubs(:signup_notification).returns(sign_up_mock)
      Notifier.expects(:signup_notification).once.returns(sign_up_mock)
      sign_up_mock.stubs(:deliver)
      sign_up_mock.expects(:deliver).once
      @user.deliver_activation_instructions!
    end
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