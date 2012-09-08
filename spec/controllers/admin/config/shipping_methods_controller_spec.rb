require  'spec_helper'

describe Admin::Config::ShippingMethodsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create(:admin_user)
    login_as(@user)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  #it "show action should render show template" do
  #  @shipping_method = create(:shipping_method)
  #  get :show, :id => @shipping_method.id
  #  response.should render_template(:show)
  #end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    ShippingMethod.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    ShippingMethod.any_instance.stubs(:valid?).returns(true)
    post :create, :shipping_method => {:name => 'UPS 3-5 day', :shipping_zone_id => 1}
    response.should redirect_to(admin_config_shipping_methods_url())
  end

  it "edit action should render edit template" do
    @shipping_method = create(:shipping_method)
    get :edit, :id => @shipping_method.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @shipping_method = create(:shipping_method)
    ShippingMethod.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @shipping_method.id
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @shipping_method = create(:shipping_method)
    ShippingMethod.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @shipping_method.id
    response.should redirect_to(admin_config_shipping_methods_url())
  end

end