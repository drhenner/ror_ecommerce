require  'spec_helper'

describe Admin::Shopping::Checkout::ShippingMethodsController do
  render_views

  before(:each) do
    activate_authlogic

    @admin_user = create_admin_user
    login_as(@user)
    controller.stubs(:verify_admin).returns(@admin_user)
    controller.stubs(:current_user).returns(@admin_user)

    @user      = FactoryGirl.create(:user)
    @cart      = FactoryGirl.create(:cart, :user=> @admin_user, :customer => @user)
    @cart_item = FactoryGirl.create(:cart_item, :cart => @cart)
    @cart.stubs(:cart_items).returns([@cart_item])

    #controller.session[:admin_cart_id] = @cart.id
    @shipping_address = FactoryGirl.create(:address, :addressable_id => @user.id, :addressable_type => 'User')

    #controller.session[:order_admin_id] = @order.id

    controller.stubs(:session_admin_cart).returns(@cart)

  end

  it "index action should render index template" do
    @order = FactoryGirl.create(:order, :user => @user, :ship_address => @shipping_address)
    controller.stubs(:session_admin_order).returns(@order)
    Address.any_instance.stubs(:shipping_method_ids).returns([1])
    controller.session[:order_admin_id] = @order.id
    get :index
    expect(response).to render_template(:index)
  end
  it "index action should render index template" do
     @order = FactoryGirl.create(:order, :user => @user, :ship_address => @shipping_address)
     controller.stubs(:session_admin_order).returns(@order)
     Address.any_instance.stubs(:shipping_method_ids).returns([])
     controller.session[:order_admin_id] = @order.id
     get :index
     expect(response).to redirect_to(admin_config_shipping_zones_url)
  end

  it "update action should render edit template when model is invalid" do
    @order        = FactoryGirl.create(:order)
    @order_item   = FactoryGirl.create(:order_item, :order => @order)
    session[:order_admin_id] = @order.id

    @shipping_rate     = FactoryGirl.create(:shipping_rate)
    @shipping_category = FactoryGirl.create(:shipping_category)
    @shipping_method   = FactoryGirl.create(:shipping_method)
    ShippingMethod.any_instance.stubs(:valid?).returns(false)
    put :update, params: { id: @shipping_method.id, shipping_category: { @shipping_category.id => nil } }
    expect(response).to  redirect_to(admin_shopping_checkout_shipping_methods_url)
  end

  it "update action should redirect when model is valid" do
    @shipping_rate     = FactoryGirl.create(:shipping_rate)
    @shipping_category = FactoryGirl.create(:shipping_category)
    @shipping_method   = FactoryGirl.create(:shipping_method)
    @order             = FactoryGirl.create(:order, user: @user, ship_address: @shipping_address)
    @order_item        = FactoryGirl.create(:order_item, :order => @order)
    controller.stubs(:order_items_with_category).returns([@order_item])
    ShippingMethod.any_instance.stubs(:valid?).returns(true)
    put :update, params: { id: @shipping_method.id, shipping_category: {@shipping_category.id => @shipping_rate.id} }
    expect(response).to redirect_to(admin_shopping_checkout_order_url)
  end
end
