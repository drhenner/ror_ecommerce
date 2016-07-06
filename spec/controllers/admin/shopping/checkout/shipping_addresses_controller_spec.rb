require  'spec_helper'

describe Admin::Shopping::Checkout::ShippingAddressesController do
  render_views

  before(:each) do
    activate_authlogic

    @admin_user = create_admin_user
    login_as(@user)
    #Admin::BaseController.stubs(:verify_admin).returns(@admin_user)
    controller.stubs(:verify_admin).returns(@admin_user)
    controller.stubs(:current_user).returns(@admin_user)

    @user      = FactoryGirl.create(:user)
    @cart      = FactoryGirl.create(:cart, :user=> @admin_user, :customer => @user)
    @cart_item = FactoryGirl.create(:cart_item, :cart => @cart)
    @cart.stubs(:cart_items).returns([@cart_item])
    #@cart.stubs(:customer).returns(@user)

    #controller.session[:admin_cart_id] = @cart.id
    @order = FactoryGirl.create(:order, :user => @user)
    #controller.session[:order_admin_id] = @order.id

    controller.stubs(:session_admin_cart).returns(@cart)
    controller.stubs(:session_admin_order).returns(@order)
    #controller.stubs(:checkout_user).returns(@user)
  end

  it "index action should render index template" do
    #@shipping_addresses = session_admin_cart.customer.shipping_addresses
    @shipping_address = FactoryGirl.create(:address, :addressable_id => @user.id, :addressable_type => 'User')
    @user.stubs(:shipping_addresses).returns([@shipping_address])
    get :index
    expect(response).to render_template(:index)
  end

  it "new action should render new template" do
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    @shipping_address = FactoryGirl.create(:address, :addressable_id => @user.id, :addressable_type => 'User')
    Address.any_instance.stubs(:valid?).returns(false)
    post :create, params: { address: @shipping_address.attributes }
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    @shipping_address = FactoryGirl.create(:address, :addressable_id => @user.id, :addressable_type => 'User')

    Address.any_instance.stubs(:valid?).returns(true)
    post :create, params: { shipping_address_id: @shipping_address.id }
    expect(response).to redirect_to(admin_shopping_checkout_shipping_methods_url)
  end

  it "create action should redirect when model is valid" do
    @shipping_address = FactoryGirl.create(:address, :addressable_id => @user.id, :addressable_type => 'User')

    Address.any_instance.stubs(:valid?).returns(true)
    post :create, params: { address: @shipping_address.attributes }
    expect(response).to redirect_to(admin_shopping_checkout_shipping_methods_url)
  end

end
