require  'spec_helper'

describe Admin::Shopping::Checkout::ShippingMethodsController do
  render_views

  before(:each) do
    activate_authlogic

    @admin_user = create(:admin_user)
    login_as(@user)
    #Admin::BaseController.stubs(:verify_admin).returns(@admin_user)
    controller.stubs(:verify_admin).returns(@admin_user)
    controller.stubs(:current_user).returns(@admin_user)

    @user  = create(:user)
    @cart = create(:cart, :user=> @admin_user, :customer => @user)
    @cart_item = create(:cart_item, :cart => @cart)
    @cart.stubs(:cart_items).returns([@cart_item])
    #@cart.stubs(:customer).returns(@user)

    #controller.session[:admin_cart_id] = @cart.id
    @shipping_address = create(:address, :addressable_id => @user.id, :addressable_type => 'User')

    #controller.session[:order_admin_id] = @order.id

    controller.stubs(:session_admin_cart).returns(@cart)

  end

  it "index action should render index template" do
    @order = create(:order, :user => @user, :ship_address => @shipping_address)
    controller.stubs(:session_admin_order).returns(@order)
    controller.session[:order_admin_id] = @order.id
    get :index
    response.should render_template(:index)
  end

  it "update action should render edit template when model is invalid" do
    @order = create(:order)
    session[:order_admin_id] = @order.id

    @shipping_rate = create(:shipping_rate)
    @shipping_category = create(:shipping_category)
    @shipping_method = create(:shipping_method)
    ShippingMethod.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @shipping_method.id, :shipping_category => {@shipping_category.id => nil}
    response.should  redirect_to(admin_shopping_checkout_shipping_methods_url)
  end

  it "update action should redirect when model is valid" do
    @shipping_rate = create(:shipping_rate)
    @shipping_category = create(:shipping_category)
    @shipping_method = create(:shipping_method)
    @order = create(:order, :user => @user, :ship_address => @shipping_address)
    @order_item = create(:order_item, :order => @order)
    controller.stubs(:order_items_with_category).returns([@order_item])
    ShippingMethod.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @shipping_method.id, :shipping_category => {@shipping_category.id => @shipping_rate.id}
    response.should redirect_to(admin_shopping_checkout_order_url)
  end
end
