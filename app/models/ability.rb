class Ability
  include CanCan::Ability

  # This method sets up the user's abilities to view  pages
  #   look at https://github.com/ryanb/cancan for more info
  def initialize(user)
    user ||= User.new # guest user

    if user.super_admin?
      can :manage, :all
    elsif user.admin?
      can :manage, :all
    else
      can :read, Order, :user_id => user.id
      can :manage, Order do |action, order|
        action != :destroy && order.state != 'complete' && order.user_id == user.id
      end

    end
  end
end