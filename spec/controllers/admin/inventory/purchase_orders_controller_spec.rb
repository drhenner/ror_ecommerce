require  'spec_helper'

describe Admin::Inventory::PurchaseOrdersController do
  render_views

  let(:variant) { FactoryGirl.create(:variant) }

  before(:each) do
    activate_authlogic

    @user = create_admin_user
    login_as(@user)
  end


  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end

  #it "show action should render show template" do
  #  @purchase_order = FactoryGirl.create(:purchase_order)
  #  get :show, :id => @purchase_order.id
  #  expect(response).to render_template(:show)
  #end

  it "new action should render new template" do
    FactoryGirl.create(:supplier)
    get :new
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
    PurchaseOrder.any_instance.stubs(:valid?).returns(false)
    post :create, params: { :purchase_order => {:ordered_at => Time.now.to_s(:db), :supplier_id => '1'} }
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
    PurchaseOrder.any_instance.stubs(:valid?).returns(true)
    post :create, params: { :purchase_order => {:ordered_at => Time.now.to_s(:db), :supplier_id => '1', "total_cost"=>"110.0",
      "notes"=>"",
      "ordered_at(1i)"=>"#{Time.now.year}", "ordered_at(2i)"=>"#{Time.now.month}", "ordered_at(3i)"=>"#{Time.now.day}", "ordered_at(4i)"=>"00", "ordered_at(5i)"=>"37",
      "estimated_arrival_on(1i)"=>"#{(Time.now + 1.day).year}", "estimated_arrival_on(2i)"=>"#{(Time.now + 1.day).month}", "estimated_arrival_on(3i)"=>"#{(Time.now + 1.day).day}",
      "purchase_order_variants_attributes"=>{"1434515852375"=>{"_destroy"=>"false", "variant_id"=>"#{variant.id}", "quantity"=>"20", "cost"=>"20.50"},
      "new_purchase_order_variants"=>{"_destroy"=>"false", "variant_id"=>"", "quantity"=>"", "cost"=>""}}} }
    expect(response).to redirect_to(admin_inventory_purchase_orders_url(notice: 'Purchase order was successfully created.'))
    expect(PurchaseOrderVariant.count).to eq 1
  end

  it "edit action should render edit template" do
    @purchase_order = FactoryGirl.create(:purchase_order)
    get :edit, params: { :id => @purchase_order.id }
    expect(response).to render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    @purchase_order = FactoryGirl.create(:purchase_order)
    PurchaseOrder.any_instance.stubs(:valid?).returns(false)
    put :update, params: { :id => @purchase_order.id, :purchase_order => {:ordered_at => Time.now.to_s(:db), :supplier_id => '1'} }
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    @purchase_order = FactoryGirl.create(:purchase_order)
    PurchaseOrder.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => @purchase_order.id, :purchase_order => {:ordered_at => Time.now.to_s(:db), :supplier_id => '1'} }
    expect(response).to redirect_to(admin_inventory_purchase_orders_url(:notice => 'Purchase order was successfully updated.'))
  end

  it "destroy action should destroy model and redirect to index action" do
    @purchase_order = FactoryGirl.create(:purchase_order)
    delete :destroy, params: { :id => @purchase_order.id }
    expect(response).to redirect_to(admin_inventory_purchase_orders_url)
    expect(PurchaseOrder.exists?(@purchase_order.id)).to eq false
  end
end
