require  'spec_helper'

describe Admin::Inventory::SuppliersController do
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
    @supplier = create(:supplier)
    get :show, :id => @supplier.id
    response.should render_template(:show)
  end

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Supplier.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    Supplier.any_instance.stubs(:valid?).returns(true)
    post :create, :supplier => {:name => 'Nike', :email => 'test@test.com'}
    response.should redirect_to(admin_inventory_suppliers_url())
  end

  it "edit action should render edit template" do
    @supplier = create(:supplier)
    get :edit, :id => @supplier.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @supplier = create(:supplier)
    Supplier.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @supplier.id
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @supplier = create(:supplier)
    Supplier.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @supplier.id
    response.should redirect_to(admin_inventory_suppliers_url())
  end

end
