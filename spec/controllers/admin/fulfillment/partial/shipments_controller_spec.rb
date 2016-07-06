require  'spec_helper'

describe Admin::Fulfillment::Partial::ShipmentsController, type: :controller do
  # fixtures :all
  render_views

  before(:each) do
    @order = FactoryGirl.create(:order)
    @order_item = FactoryGirl.create(:order_item, :order => @order)
    activate_authlogic
    @user = FactoryGirl.create(:admin_user)
    login_as(@user)
  end

  it "new action should render new template" do
    get :new, params: { :order_id => @order.number }
    expect(response).to render_template(:new)
  end

  it "create action should render new template when model is invalid" do
   # shipment = Factory.build(:shipment)
   #@order_item.update_attribute(:state, 'paid')
    #Shipment.any_instance.stubs(:valid?).returns(false)
    Order.any_instance.stubs(:create_shipments_with_order_item_ids).returns(false)
    post :create, params: { :order_item_ids => [@order_item.id], :order_id => @order.number }
    expect(response).to render_template(:new)
  end

  it "create action should redirect when model is valid" do
   # shipment = Factory.build(:shipment)
    Order.any_instance.stubs(:create_shipments_with_order_item_ids).returns(true)
    post :create, params: { :order_item_ids => [@order_item.id], :order_id => @order.number }
    expect(response).to redirect_to(edit_admin_fulfillment_order_url( @order ))
  end

  it "update action should render new template when model is invalid" do
   # shipment = Factory.build(:shipment)
    #Shipment.any_instance.stubs(:valid?).returns(false)
    Order.any_instance.stubs(:create_shipments_with_order_item_ids).returns(false)
    put :update, params: { order_id: @order.number, id: 0, order: { :order_item_ids => []} }
    expect(response).to render_template(:new)
  end

  it "update action should redirect when model is valid" do
   # shipment = Factory.build(:shipment)
    Order.any_instance.stubs(:create_shipments_with_order_item_ids).returns(true)
    put :update, params: { :order => { :order_item_ids => [@order_item.id]}, :order_id => @order.number, :id => 0 }
    expect(response).to redirect_to(edit_admin_fulfillment_order_url( @order ))
  end
end
