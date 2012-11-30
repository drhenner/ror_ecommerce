# This is how cancan controls authorization.  For more details look at https://github.com/ryanb/cancan

class AdminAbility
  include CanCan::Ability

  # This method sets up the user's abilities to view admin pages
  #   look at https://github.com/ryanb/cancan for more info
  def initialize(user)
    user ||= User.new # guest user will not be allowed in the admin section

    if user.super_admin?
      can :manage, :all
    elsif user.admin?
      #can :manage, :all
      can :read, :all
      can :view_users, User do
        user.admin?
      end
      #authorize! :view_users, @user
      can :create_users, User do
        user.super_admin?
      end
      #authorize! :create_users, @user
      can :create_orders, User
    else

    end
  end
end
