require  'spec_helper'

describe Admin::Inventory::ReceivingsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = create_admin_user
    login_as(@user)
    @purchase_order = FactoryGirl.create(:purchase_order)
  end

  #it "show action should render show template" do
  #  get :show, :id => @purchase_order.id
  #  expect(response).to render_template(:show)
  #end

  it "index action should render index template" do
    get :index
    expect(response).to render_template(:index)
  end

  it "edit action should render edit template" do
    get :edit, params: { id: @purchase_order.id }
    expect(response).to render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    PurchaseOrder.any_instance.stubs(:valid?).returns(true)
    put :update, params: { id: @purchase_order.id, purchase_order: {:receive_po => '1'} }
    expect(response).to redirect_to(admin_inventory_receivings_url( :notice => 'Purchase order was successfully updated.'))
  end
end
