module Hadean
  module TestHelpers
    
    def login_as(user)
      activate_authlogic
      user_session_for user
      
      #u ||= Factory(user)
      #controller.stubs(:current_user).returns(u)
      #u
    end
    
    def user_session_for(user)
      UserSession.create(user)
    end
    
    def current_user
      UserSession.find.user
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