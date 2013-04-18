module Hadean
  module TestHelpers

    def create_admin_user(args = {})
      @uusseerr = FactoryGirl.build(:user, args)
      @uusseerr.stubs(:set_referral_registered_at).returns(false)
      @uusseerr.save
      @uusseerr.stubs(:roles).returns([Role.find_by_name(Role::ADMIN)])
      @uusseerr
    end

    def create_real_admin_user(args = {})
      @uusseerr = FactoryGirl.build(:user, args)
      @uusseerr.stubs(:set_referral_registered_at).returns(false)
      @uusseerr.save
      @uusseerr.role_ids = [Role.find_by_name(Role::ADMIN).id]
      @uusseerr.save
      @uusseerr
    end
    def create_super_admin_user(args = {})
      @uusseerr = FactoryGirl.build(:user, args)
      @uusseerr.stubs(:set_referral_registered_at).returns(false)
      #@uusseerr.stubs(:admin?).returns(true)
      #@uusseerr.stubs(:super_admin?).returns(false)
      @uusseerr.stubs(:roles).returns([Role.find_by_name(Role::SUPER_ADMIN)])
      @uusseerr.save
      @uusseerr
    end

    def login_as(user)
      user_session_for user
      controller.stubs(:current_user).returns(user)
    end

    def user_session_for(user)
      UserSession.create(user)
    end

    def set_current_user(user = create(:user))
      UserSession.create(user)
      controller.stubs(:current_user).returns(user)
    end

    def create_cart(customer, admin_user = nil, variants = [])
      user = admin_user || customer
      test_cart = Cart.create(:user_id => user.id, :customer_id => customer.id)

      variants.each do |variant|
        test_cart.add_variant(variant.id, customer)
      end

      @controller.stubs(:session_cart).returns(test_cart)
    end

    def setup_10_dollar_referral(referring_user, referral_email, referral_user = nil, quantity_needed = 2)
      referral_bonus    = FactoryGirl.create(:referral_bonus, :amount => 1000, :quantity_needed => quantity_needed)
      referral_program  = FactoryGirl.create(:referral_program, :referral_bonus => referral_bonus)# refer 2 get $10
      referral          = FactoryGirl.create(:referral,
                          :email            => referral_email,
                          :referring_user   => referring_user,
                          :referral_user    => referral_user,
                          :referral_program => referral_program,
                          :registered_at    => nil)
      #
    end
  end
end
