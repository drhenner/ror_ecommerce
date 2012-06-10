require  'spec_helper'

describe Admin::Merchandise::Wizards::BrandsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create(:admin_user)
    login_as(@user)
    controller.session[:product_wizard] = {}
  end

  it "index action should render index template" do
    @brand = create(:brand)
    get :index
    response.should render_template(:index)
  end

  it "create action should render new template when model is invalid" do
    Brand.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:index)
  end

  it "create action should redirect when model is valid" do
    Brand.any_instance.stubs(:valid?).returns(true)
    post :create
    controller.session[:product_wizard][:brand_id].should_not be_nil
    response.should redirect_to(admin_merchandise_wizards_product_types_url)
  end

  it "update action should render edit template when model is invalid" do
    @brand = create(:brand)
    Brand.stubs(:find_by_id).returns(nil)
    put :update, :id => @brand.id
    controller.session[:product_wizard][:brand_id].should be_nil
    response.should render_template(:index)
  end

  it "update action should redirect when model is valid" do
    @brand = create(:brand)
    #Brand.stubs(:find_by_id).returns(@brand)
    #Brand.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @brand.id
    controller.session[:product_wizard][:brand_id].should_not be_nil
    response.should redirect_to(admin_merchandise_wizards_product_types_url)
  end
end
