require  'spec_helper'

describe Admin::Shopping::Checkout::ShippingMethodsController do
  render_views

  before(:each) do
    activate_authlogic

    @admin_user = Factory(:admin_user)
    login_as(@user)
    #Admin::BaseController.stubs(:verify_admin).returns(@admin_user)
    controller.stubs(:verify_admin).returns(@admin_user)
    controller.stubs(:current_user).returns(@admin_user)

    @user  = Factory(:user)
    @cart = Factory(:cart, :user=> @admin_user, :customer => @user)
    @cart_item = Factory(:cart_item, :cart => @cart)
    @cart.stubs(:cart_items).returns([@cart_item])
    #@cart.stubs(:customer).returns(@user)

    #controller.session[:admin_cart_id] = @cart.id
    @shipping_address = Factory(:address, :addressable_id => @user.id, :addressable_type => 'User')

    #controller.session[:order_admin_id] = @order.id

    controller.stubs(:session_admin_cart).returns(@cart)

  end

  it "index action should render index template" do
    @order = Factory(:order, :user => @user, :ship_address => @shipping_address)
    controller.stubs(:session_admin_order).returns(@order)
    controller.session[:order_admin_id] = @order.id
    get :index
    response.should render_template(:index)
  end

  it "update action should render edit template when model is invalid" do
    @order = Factory(:order)
    session[:order_admin_id] = @order.id

    @shipping_rate = Factory(:shipping_rate)
    @shipping_category = Factory(:shipping_category)
    @shipping_method = Factory(:shipping_method)
    ShippingMethod.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @shipping_method.id, :shipping_category => {@shipping_category.id => nil}
    response.should  redirect_to(admin_shopping_checkout_shipping_methods_url)
  end

  it "update action should redirect when model is valid" do
    @shipping_rate = Factory(:shipping_rate)
    @shipping_category = Factory(:shipping_category)
    @shipping_method = Factory(:shipping_method)
    @order = Factory(:order, :user => @user, :ship_address => @shipping_address)
    @order_item = Factory(:order_item, :order => @order)
    controller.stubs(:order_items_with_category).returns([@order_item])
    ShippingMethod.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @shipping_method.id, :shipping_category => {@shipping_category.id => @shipping_rate.id}
    response.should redirect_to(admin_shopping_checkout_order_url)
  end
end
