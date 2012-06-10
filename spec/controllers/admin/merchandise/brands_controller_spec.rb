require  'spec_helper'

describe Admin::Merchandise::BrandsController do
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
    @brand = create(:brand)
    get :show, :id => @brand.id
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Brand.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    Brand.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(admin_merchandise_brand_url(assigns[:brand]))
  end

  it "edit action should render edit template" do
    @brand = create(:brand)
    get :edit, :id => @brand.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @brand = create(:brand)
    Brand.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @brand.id
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @brand = create(:brand)
    Brand.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @brand.id
    response.should redirect_to(admin_merchandise_brand_url(assigns[:brand]))
  end

end
