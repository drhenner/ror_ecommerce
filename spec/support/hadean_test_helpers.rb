module Hadean
  module TestHelpers

    def login_as(user)
      #activate_authlogic
      user_session_for user

      #u ||= create(user)
      controller.stubs(:current_user).returns(user)
      #u
    end

    def user_session_for(user)
      UserSession.create(user)
    end

    #def current_user
    #  UserSession.find.user
    #end

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
    #def admin_role
    #  role_by_name Role::ADMIN
    #end
    #
    #def role_by_name name
    #  Role.find_by_name name
    #end
  end
end