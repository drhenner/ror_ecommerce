require 'spec_helper'

describe User do
  context "Valid User" do
    before(:each) do
      @user = build(:user)
    end

    it "should be valid with minimum attributes" do
      @user.should be_valid
    end

  end

  context "Invalid User" do
    before(:each) do
      @user = build(:user, :form_birth_date => '05/05/1900')
    end

    it "should be valid with minimum attributes(Too old)" do
      @user = build(:user, :form_birth_date => '05/05/1900')
      @user.should_not be_valid
    end

    it "should be valid with minimum attributes(Not born yet)" do
      now = Time.now + 10.days
      @user = build(:user, :form_birth_date => now.strftime("%m/%d/%Y"))
      @user.should_not be_valid
    end
  end
end


describe User, ".form_birth_date(val)" do
  it "should return the correct b-day" do
    user = create(:user, :form_birth_date => '05/18/1975')
    #should_receive(:authenticate).with("password").and_return(true)
    user.birth_date.should_not be_blank
    user.form_birth_date.should == '05/18/1975'
    #ActiveSupport::TimeZone.us_zones.map(&:to_s).include?(user.time_zone).should be_true
  end

  it "should return the correct b-day" do
    user = create(:user, :form_birth_date => '')
    #should_receive(:authenticate).with("password").and_return(true)
    user.birth_date.should be_blank
    user.form_birth_date.should == nil
    #ActiveSupport::TimeZone.us_zones.map(&:to_s).include?(user.time_zone).should be_true
  end
end


describe User, ".name" do
  it "should return the correct name" do
    user = build(:registered_user)
    #should_receive(:authenticate).with("password").and_return(true)
    user.stubs(:first_name).returns("Fred")
    user.stubs(:last_name).returns("Flint")
    user.name.should == "Fred Flint"
  end
end

describe User, '.registered_user?' do
  it "should return false for an unregistered user" do
    user = build(:user)
    user.registered_user?.should be_false
  end
  it "should return true for a registered user" do
    user = registered_user_factory
    user.registered_user?.should be_true
  end
  it "should return true for a user registered_with_credit" do
    user = registered_with_credit_user_factory
    user.registered_user?.should be_true
  end
end

describe User, "instance methods" do

  before(:each) do
    User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
  end

  context ".admin?" do
    it 'ahould be an admin' do
      user = create(:admin_user)
      user.admin?.should be_true
    end

    it 'ahould be an admin' do
      user = create(:super_admin_user)
      user.admin?.should be_true
    end

    it 'ahould not be an admin' do
      user = create(:user)
      user.admin?.should be_false
    end
  end
end

describe User, "instance methods" do
  before(:each) do
    User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
    @user = create(:user)
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
      product = create(:product)
      @user.might_be_interested_in_these_products.include?(product).should be_true
    end

    #pending "add your specific find products method here"
  end

  context ".format_birth_date(b_date)" do
    it 'should return a US date formatted correctly' do
      @user.format_birth_date('12/17/1975')
      @user.birth_date.should_not be_nil
      @user.birth_date.strftime('%m/%d/%Y').should == '12/17/1975'
    end

    it 'should return nil if no date is given' do
      @user.format_birth_date('')
      @user.birth_date.should be_nil
    end
  end

  context ".billing_address" do
    # default_billing_address ? default_billing_address : default_shipping_address
    it 'should return nil if you dont have an address' do
      #add = create(:address, :addressable => @user, :default => true)
      @user.billing_address.should be_nil
    end

    it 'should use your shipping address if you dont have a default billing address' do
      add = create(:address, :addressable => @user, :default => true)
      @user.billing_address.should == add
    end

    it 'should use your default billing address if you have one available' do
      add = create(:address, :addressable => @user, :default => true)
      bill_add = create(:address, :addressable => @user, :billing_default => true)
      @user.billing_address.should == bill_add
    end

    it 'should return the first address if not defaults are set' do
      #add = create(:address, :addressable => @user, :default => true)
      add = create(:address, :addressable => @user)
      @user.billing_address.should == add
    end
  end

  context ".shipping_address" do
    # default_billing_address ? default_billing_address : default_shipping_address
    it 'should return nil if you dont have an address' do
      #add = create(:address, :addressable => @user, :default => true)
      @user.shipping_address.should be_nil
    end

    it 'should use your default shipping address if you have one available' do
      add = create(:address, :addressable => @user, :default => true)
      bill_add = create(:address, :addressable => @user, :billing_default => true)
      @user.shipping_address.should == add
    end

    it 'should return the first address if not defaults are set' do
      #add = create(:address, :addressable => @user, :default => true)
      add = create(:address, :addressable => @user)
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
    #"\"#{name}\" <#{email}>"
    it 'should show the persons name and email address' do
      @user.email       = 'myfake@email.com'
      @user.first_name  = 'Dave'
      @user.last_name   = 'Commerce'
      @user.email_address_with_name.should == '"Dave Commerce" <myfake@email.com>'
    end
  end

  context ".get_cim_profile" do
    pending "test for get_cim_profile"
  end

  context ".merchant_description" do
    # [name, default_shipping_address.try(:address_lines)].compact.join(', ')
    it 'should show the name and address lines' do
      address = create(:address, :address1 => 'Line one street', :address2 => 'Line two street')
      @user.first_name = 'First'
      @user.last_name  = 'Second'

      @user.stubs(:default_shipping_address).returns(address)
      @user.merchant_description.should == 'First Second, Line one street, Line two street'
    end

    it 'should show the name and address lines without address2' do
      address = create(:address, :address1 => 'Line one street', :address2 => nil)
      @user.first_name = 'First'
      @user.last_name  = 'Second'

      @user.stubs(:default_shipping_address).returns(address)
      @user.merchant_description.should == 'First Second, Line one street'
    end
  end

end

describe User, 'store_credit methods' do
  context '.start_store_credits' do
    it 'should create store_credit object on create' do
      user = create(:user)
      user.store_credit.should_not be_nil
      user.store_credit.id.should_not be_nil
    end
  end
end

describe User, 'private methods' do

  before(:each) do
    User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
    @user = build(:user)
  end

  context ".password_required?" do
    it 'should require a password if the crypted password is blank' do
      @user.crypted_password = nil
      @user.send(:password_required?).should be_true
    end

    it 'should not require a password if the crypted password is present' do
      @user.crypted_password = 'blah'
      @user.send(:password_required?).should be_false
    end
  end

  context ".create_cim_profile" do
    pending "test for create_cim_profile"
  end

  context ".before_validation_on_create" do
    #Notifier.expects(:signup_notification).once.returns(sign_up_mock)
    it 'should assign the access_token' do
      @user.expects(:before_validation_on_create).once
      @user.save
    end
    it 'should assign the access_token' do
      @user.save
      @user.access_token.should_not be_nil
    end
  end

  context ".user_profile" do
    #{:merchant_customer_id => self.id, :email => self.email, :description => self.merchant_description}
    it 'should return a hash of user info' do
      @user.save
      profile = @user.send(:user_profile)
      profile.keys.include?(:merchant_customer_id).should be_true
      profile.keys.include?(:email).should be_true
      profile.keys.include?(:description).should be_true
    end
  end
end

describe User, "#admin_grid(params = {})" do
  it "should return users " do
    User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
    user1 = create(:user)
    user2 = create(:user)
    admin_grid = User.admin_grid
    admin_grid.size.should == 2
    admin_grid.include?(user1).should be_true
    admin_grid.include?(user2).should be_true
  end
end