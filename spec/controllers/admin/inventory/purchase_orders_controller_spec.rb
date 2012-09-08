require  'spec_helper'

describe Admin::Inventory::PurchaseOrdersController do
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
  #  @purchase_order = create(:purchase_order)
  #  get :show, :id => @purchase_order.id
  #  response.should render_template(:show)
  #end

  it "new action should render new template" do
    create(:supplier)
    get :new
    response.should render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    PurchaseOrder.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end

  it "create action should redirect when model is valid" do
    PurchaseOrder.any_instance.stubs(:valid?).returns(true)
    post :create, :purchase_order => {:ordered_at => Time.now.to_s(:db), :supplier_id => '1'}
    response.should redirect_to(admin_inventory_purchase_orders_url(:notice => 'Purchase order was successfully created.'))
  end

  it "edit action should render edit template" do
    @purchase_order = create(:purchase_order)
    get :edit, :id => @purchase_order.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @purchase_order = create(:purchase_order)
    PurchaseOrder.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @purchase_order.id
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @purchase_order = create(:purchase_order)
    PurchaseOrder.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @purchase_order.id
    response.should redirect_to(admin_inventory_purchase_orders_url(:notice => 'Purchase order was successfully updated.'))
  end

  it "destroy action should destroy model and redirect to index action" do
    @purchase_order = create(:purchase_order)
    delete :destroy, :id => @purchase_order.id
    response.should redirect_to(admin_inventory_purchase_orders_url)
    PurchaseOrder.exists?(@purchase_order.id).should be_false
  end
end
