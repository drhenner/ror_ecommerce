require  'spec_helper'

describe Admin::Merchandise::BrandsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create_admin_user
    login_as(@user)
  end

  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end

  it "show action should render show template" do
    @brand = create(:brand)
    get :show, :id => @brand.id
    expect(response).to render_template(:show)
  end

  it "new action should render new template" do
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Brand.any_instance.stubs(:valid?).returns(false)
    post :create, :brand => {:name => 'RoR ecommerce'}
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    Brand.any_instance.stubs(:valid?).returns(true)
    post :create, :brand => {:name => 'RoR ecommerce'}
    expect(response).to redirect_to(admin_merchandise_brand_url(assigns[:brand]))
  end

  it "edit action should render edit template" do
    @brand = create(:brand)
    get :edit, :id => @brand.id
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @brand = create(:brand)
    Brand.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @brand.id, :brand => {:name => 'RoR ecommerce'}
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @brand = create(:brand)
    Brand.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @brand.id, :brand => {:name => 'RoR ecommerce'}
    expect(response).to redirect_to(admin_merchandise_brand_url(assigns[:brand]))
  end

end
