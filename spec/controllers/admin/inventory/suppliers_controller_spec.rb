require  'spec_helper'

describe Admin::Inventory::SuppliersController do
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
    @supplier = FactoryGirl.create(:supplier)
    get :show, params: {id: @supplier.id}
    expect(response).to render_template(:show)
  end

  it "new action should render new template" do
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    Supplier.any_instance.stubs(:valid?).returns(false)
    post :create, params: { supplier: {:name => 'John'} }
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    Supplier.any_instance.stubs(:valid?).returns(true)
    post :create, params: { supplier: {:name => 'Nike', :email => 'test@test.com'} }
    expect(response).to redirect_to(admin_inventory_suppliers_url())
  end

  it "edit action should render edit template" do
    @supplier = FactoryGirl.create(:supplier)
    get :edit, params: { id: @supplier.id }
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @supplier = FactoryGirl.create(:supplier)
    Supplier.any_instance.stubs(:valid?).returns(false)
    put :update, params: { id: @supplier.id, :supplier => {:name => 'John', :email => 'test@test.com'} }
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @supplier = FactoryGirl.create(:supplier)
    Supplier.any_instance.stubs(:valid?).returns(true)
    put :update, params: { id: @supplier.id, :supplier => {:name => 'John', :email => 'test@test.com'} }
    expect(response).to redirect_to(admin_inventory_suppliers_url())
  end

end
