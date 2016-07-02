require  'spec_helper'

describe Admin::Shopping::Checkout::OrdersController do
  render_views

  before(:each) do
    activate_authlogic

    @admin_user = create_admin_user
    login_as(@user)
    controller.stubs(:verify_admin).returns(@admin_user)
    controller.stubs(:current_user).returns(@admin_user)

    @user  = FactoryGirl.create(:user)
    @cart  = FactoryGirl.create(:cart, :user=> @admin_user, :customer => @user)
    @cart_item = FactoryGirl.create(:cart_item, :cart => @cart)
    @cart.stubs(:cart_items).returns([@cart_item])
    #@cart.stubs(:customer).returns(@user)

    controller.session[:admin_cart_id] = @cart.id
    @shipping_address = create(:address, :addressable_id => @user.id, :addressable_type => 'User')

    @order = FactoryGirl.create(:order, :user => @user, :ship_address => @shipping_address)
    controller.stubs(:session_admin_order).returns(@order)
    controller.session[:order_admin_id] = @order.id

    controller.stubs(:session_admin_cart).returns(@cart)

    controller.stubs(:next_admin_order_form).returns(nil)

  end

  it "show action should render show template" do
    @order.stubs(:order_items).returns([])
    get :show
    expect(response).to redirect_to admin_shopping_products_url
  end
  it "show action should render show template" do
    @order_item = FactoryGirl.create(:order_item, :order => @order)
    @order.stubs(:order_items).returns([])
    get :show
    expect(response).to render_template(:show)
  end

  it "update action should render edit template when cc transaction is invalid" do
    @order.stubs(:complete?).returns(true)
    put :update#, :id => @order.id
    expect(response).to redirect_to( admin_history_order_url(@order))
  end

end
