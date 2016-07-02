require  'spec_helper'

describe Admin::Merchandise::ProductTypesController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create_admin_user
    login_as(@user)

  end

  it "index action should render index template" do
    @product_type = FactoryGirl.create(:product_type)
    get :index
    expect(response).to render_template(:index)
  end

  it "new action should render new template" do
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    ProductType.any_instance.stubs(:valid?).returns(false)
    post :create, params: { :product_type => {:name => 'dis', :parent_id => 1} }
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    @product_type = build(:product_type)
    ProductType.any_instance.stubs(:valid?).returns(true)
    post :create, params: { product_type: @product_type.attributes.reject {|k,v| !['name','parent_id'].include?(k)} }
    expect(response).to redirect_to(admin_merchandise_product_types_url)
  end

  it "edit action should render edit template" do
    @product_type = FactoryGirl.create(:product_type)
    get :edit, params: { :id => @product_type.id }
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @product_type = FactoryGirl.create(:product_type)
    ProductType.any_instance.stubs(:valid?).returns(false)
    put :update, params: { :id => @product_type.id, :product_type => {:name => 'dis', :parent_id => nil} }
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @product_type = FactoryGirl.create(:product_type)
    ProductType.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => @product_type.id, :product_type => {:name => 'dis', :parent_id => nil} }
    expect(response).to redirect_to(admin_merchandise_product_types_url)
  end

  it "destroy action should destroy model and redirect to index action" do
    @product_type = FactoryGirl.create(:product_type)
    delete :destroy, params: { id: @product_type.id }
    expect(response).to redirect_to(admin_merchandise_product_types_url)
    expect(ProductType.find(@product_type.id).active).to eq false
  end
end
