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

    it "should be valid without first_name" do
      @user = build(:user, :first_name => '')
      @user.should_not be_valid
    end

  end
end

describe User, ".name" do
  it "should return the correct name" do
    user = build(:user)
    #should_receive(:authenticate).with("password").and_return(true)
    user.stubs(:first_name).returns("Fred")
    user.stubs(:last_name).returns("Flint")
    user.name.should == "Fred Flint"
  end
end

describe User, "instance methods" do

  before(:each) do
    User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
  end

  context ".admin?" do
    it 'ahould be an admin' do
      user = create_admin_user
      expect(user.admin?).to be true
    end

    it 'ahould be an admin' do
      user = create_super_admin_user
      expect(user.admin?).to be true
    end

    it 'ahould not be an admin' do
      user = create(:user)
      expect(user.admin?).to be false
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
      expect(@user.active?).to be false
      @user.state = 'inactive'
      expect(@user.active?).to be false
    end

  end

  context ".display_active" do
    it 'should not be active' do
      @user.state = 'canceled'
      @user.display_active.should == 'false'
    end

    it 'should not be active' do
      @user.state = 'inactive'
      @user.display_active.should == 'false'
    end

    it 'should be active' do
      @user.state = 'active'
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
      expect(@user.might_be_interested_in_these_products.include?(product)).to be true
    end

    #pending "add your specific find products method here"
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
    # registered?

    it 'should not be a registered user' do
      @user.state = 'active'
      expect(@user.registered_user?).to be true
    end

    it 'should not be a registered user' do
      @user.state = 'canceled'
      expect(@user.registered_user?).to be false
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
    skip "test for get_cim_profile"
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
      expect(@user.send(:password_required?)).to be true
    end

    it 'should not require a password if the crypted password is present' do
      @user.crypted_password = 'blah'
      expect(@user.send(:password_required?)).to be false
    end
  end

  context ".create_cim_profile" do
    skip "test for create_cim_profile"
  end

  context ".before_validation_on_create" do
    #Notifier.expects(:signup_notification).once.returns(sign_up_mock)
    it 'should assign the access_token' do
      user = build(:user)
      user.expects(:before_validation_on_create).once
      user.save
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
      expect(profile.keys.include?(:merchant_customer_id)).to be true
      expect(profile.keys.include?(:email)).to be true
      expect(profile.keys.include?(:description)).to be true
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
    expect(admin_grid.include?(user1)).to be true
    expect(admin_grid.include?(user2)).to be true
  end
end
