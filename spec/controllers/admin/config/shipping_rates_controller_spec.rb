require  'spec_helper'

describe Admin::Config::ShippingRatesController, type: :controller do
  render_views

  before(:each) do
    activate_authlogic
    @user = create_super_admin_user
    login_as(@user)
  end

  it "index action should render index template" do
    ShippingMethod.stubs(:all).returns([])
    get :index
    expect(response).to redirect_to(admin_config_shipping_methods_url)
  end

  it "index action should render index template" do
    shipping_method = FactoryGirl.create(:shipping_method)
    ShippingMethod.stubs(:all).returns([shipping_method])
    get :index
    expect(response).to render_template(:index)
  end

  it "show action should render show template" do
    @shipping_rate = FactoryGirl.create(:shipping_rate)
    get :show, params: { id: @shipping_rate.id }
    expect(response).to render_template(:show)
  end

  it "new action should render new template" do
    ShippingCategory.stubs(:all).returns([])
    get :new
    expect(response).to redirect_to(new_admin_config_shipping_category_url)
  end

  it "new action should render new template" do
    shipping_category = FactoryGirl.create(:shipping_category)
    ShippingCategory.stubs(:all).returns([shipping_category])
    ShippingMethod.stubs(:all).returns([])
    get :new
    expect(response).to redirect_to(new_admin_config_shipping_method_url)
  end

  it "new action should render new template" do
    shipping_category = FactoryGirl.create(:shipping_category)
    ShippingCategory.stubs(:all).returns([shipping_category])
    shipping_method = FactoryGirl.create(:shipping_method)
    ShippingMethod.stubs(:all).returns([shipping_method])
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    ShippingRate.any_instance.stubs(:valid?).returns(false)
    post :create, params: { shipping_rate: {:shipping_category_id => 1, :shipping_method_id => 1, :shipping_rate_type_id => 1} }
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    ShippingRate.any_instance.stubs(:valid?).returns(true)
    post :create, params: { shipping_rate: {:shipping_category_id => 1, :shipping_method_id => 1, :shipping_rate_type_id => 1} }
    expect(response).to redirect_to(admin_config_shipping_rate_url(assigns[:shipping_rate]))
  end

  it "edit action should render edit template" do
    @shipping_rate = FactoryGirl.create(:shipping_rate)
    get :edit, params: { id: @shipping_rate.id }
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @shipping_rate = FactoryGirl.create(:shipping_rate)
    ShippingRate.any_instance.stubs(:valid?).returns(false)
    put :update, params: { :id => @shipping_rate.id, :shipping_rate =>  {:shipping_category_id => 1, :shipping_method_id => 1, :shipping_rate_type_id => 1} }
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @shipping_rate = FactoryGirl.create(:shipping_rate)
    ShippingRate.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => @shipping_rate.id, :shipping_rate =>  {:shipping_category_id => 1, :shipping_method_id => 1, :shipping_rate_type_id => 1}}
    expect(response).to redirect_to(admin_config_shipping_rate_url(assigns[:shipping_rate]))
  end

end
