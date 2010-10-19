=begin
require 'spec_helper'

describe Admin::History::OrdersController do

  def mock_order(stubs={})
    @mock_order ||= mock_model(Admin::History::Order, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all admin_history_orders as @admin_history_orders" do
      Admin::History::Order.stub(:all) { [mock_order] }
      get :index
      assigns(:admin_history_orders).should eq([mock_order])
    end
  end

  describe "GET show" do
    it "assigns the requested order as @order" do
      Admin::History::Order.stub(:find).with("37") { mock_order }
      get :show, :id => "37"
      assigns(:order).should be(mock_order)
    end
  end

end
=end