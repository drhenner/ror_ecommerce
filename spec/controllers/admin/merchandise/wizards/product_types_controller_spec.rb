require  'spec_helper'

describe Admin::Merchandise::Wizards::ProductTypesController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create(:admin_user)
    login_as(@user)
    controller.session[:product_wizard] = {}
    #@brand = create(:brand)
    controller.session[:product_wizard][:brand_id] = 7# @brand.id
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "create action should render new template when model is invalid" do
    ProductType.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:index)
  end

  it "create action should redirect when model is valid" do
    ProductType.any_instance.stubs(:valid?).returns(true)
    post :create, :product_type => {:name => 'prod type'}
    response.should render_template(:index) #redirect_to(admin_merchandise_wizards_properties_url)
  end

  it "update action should render edit template when model is invalid" do
    @product_type = create(:product_type)
    ProductType.stubs(:find_by_id).returns(nil)
    put :update, :id => @product_type.id
    response.should render_template(:index)
  end

  it "update action should redirect when model is valid" do
    @product_type = create(:product_type)
    #ProductType.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @product_type.id
    controller.session[:product_wizard][:product_type_id].should == @product_type.id
    response.should redirect_to(admin_merchandise_wizards_properties_url)
  end
end
