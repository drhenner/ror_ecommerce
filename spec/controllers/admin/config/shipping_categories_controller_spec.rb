require  'spec_helper'

describe Admin::Config::ShippingCategoriesController do
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

  it "show action should render show template" do
    @shipping_category = create(:shipping_category)
    get :show, :id => @shipping_category.id
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    ShippingCategory.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    ShippingCategory.any_instance.stubs(:valid?).returns(true)
    post :create, :shipping_category => {:name => 'clothing'}
    response.should redirect_to(admin_config_shipping_rates_url)
  end

  it "edit action should render edit template" do
    @shipping_category = create(:shipping_category)
    get :edit, :id => @shipping_category.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @shipping_category = create(:shipping_category)
    ShippingCategory.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @shipping_category.id
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @shipping_category = create(:shipping_category)
    ShippingCategory.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @shipping_category.id, :shipping_category => {:name => 'clothing'}
    response.should redirect_to(admin_config_shipping_rates_url())
  end
end