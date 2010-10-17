class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user

    if user.super_admin?
      can :manage, :all
    elsif user.admin?
      debugger
      can :manage, :all
    else
      can :read, Order, :user_id => user.id
      can :manage, Order do |action, order|
        action != :destroy && order.state != 'complete' && order.user_id == user.id
      end
      
    end
  end
end