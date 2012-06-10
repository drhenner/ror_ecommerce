require  'spec_helper'

describe Admin::History::AddressesController do
  render_views

  before(:each) do
    activate_authlogic
    @user = create(:admin_user)
    login_as(@user)
    @order = create(:order)
  end

  it "index action should render index template" do
    get :index, :order_id => @order.number
    response.should render_template(:index)
  end

  it "show action should render show template" do
    @address = create(:address)
    get :show, :id => @address.id, :order_id => @order.number
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new, :order_id => @order.number
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Address.any_instance.stubs(:valid?).returns(false)
    post :create, :order_id => @order.number
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    @address = build(:address)
    Address.any_instance.stubs(:valid?).returns(true)
    post :create, :order_id => @order.number,:admin_history_address => @address.attributes
    response.should redirect_to(admin_history_order_url(@order))
  end

  it "edit action should render edit template" do
    @address = create(:address)
    get :edit, :id => @address.id, :order_id => @order.number
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @address = create(:address)
    Order.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @address.id, :order_id => @order.number
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @address = create(:address)
    Address.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @address.id, :order_id => @order.number
    response.should redirect_to(admin_history_order_url(@order))
  end

end