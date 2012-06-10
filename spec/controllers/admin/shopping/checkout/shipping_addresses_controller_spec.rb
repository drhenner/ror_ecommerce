require  'spec_helper'

describe Admin::Shopping::Checkout::ShippingAddressesController do
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
    @order = create(:order, :user => @user)
    #controller.session[:order_admin_id] = @order.id

    controller.stubs(:session_admin_cart).returns(@cart)
    controller.stubs(:session_admin_order).returns(@order)
    #controller.stubs(:checkout_user).returns(@user)
  end

  it "index action should render index template" do
    #@shipping_addresses = session_admin_cart.customer.shipping_addresses
    @shipping_address = create(:address, :addressable_id => @user.id, :addressable_type => 'User')
    @user.stubs(:shipping_addresses).returns([@shipping_address])
    get :index
    response.should render_template(:index)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    @shipping_address = create(:address, :addressable_id => @user.id, :addressable_type => 'User')
    Address.any_instance.stubs(:valid?).returns(false)
    post :create, :address => @shipping_address.attributes
    response.should render_template(:index)
  end

  it "create action should redirect when model is valid" do
    @shipping_address = create(:address, :addressable_id => @user.id, :addressable_type => 'User')

    Address.any_instance.stubs(:valid?).returns(true)
    post :create, :shipping_address_id => @shipping_address.id
    response.should redirect_to(admin_shopping_checkout_order_url)
  end

  it "create action should redirect when model is valid" do
    @shipping_address = create(:address, :addressable_id => @user.id, :addressable_type => 'User')

    Address.any_instance.stubs(:valid?).returns(true)
    post :create, :address => @shipping_address.attributes
    response.should redirect_to(admin_shopping_checkout_order_url)
  end

  it "update action should render edit template when model is invalid" do
    @shipping_address = create(:address, :addressable_id => @user.id, :addressable_type => 'User')
    Address.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @shipping_address.id
    response.should render_template(:index)
  end

  it "update action should redirect when model is valid" do
    @shipping_address = create(:address, :addressable_id => @user.id, :addressable_type => 'User')
    Address.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @shipping_address.id, :address => @shipping_address.attributes
    response.should redirect_to(admin_shopping_checkout_order_url)
  end
end
