class AdminAbility
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.super_admin?
      can :manage, :all
    elsif user.admin?
      can :read, :all
      can :view_users, User
      can :create_orders, User
      can :manage_fulfillment, Order
      can :manage_generic, :coupon
    elsif user.warehouse?
      can :read, Product
      can :read, Variant
      can :manage, PurchaseOrder
      can :manage_fulfillment, Order
      can :read, Order
    elsif user.customer_service?
      can :read, Order
      can :read, User
      can :view_users, User
      can :manage, ReturnAuthorization
    elsif user.report?
      can :read_reports, :all
    end
  end
end
