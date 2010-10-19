=begin
require 'spec_helper'

describe Myaccount::OrdersController do

  def mock_order(stubs={})
    @mock_order ||= mock_model(Myaccount::Order, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all myaccount_orders as @myaccount_orders" do
      Order.stub(:all) { [mock_order] }
      get :index
      assigns(:orders).should eq([mock_order])
    end
  end

  describe "GET show" do
    it "assigns the requested order as @order" do
      Order.stub(:find).with("37") { mock_order }
      get :show, :id => "37"
      assigns(:order).should be(mock_order)
    end
  end

end
=end