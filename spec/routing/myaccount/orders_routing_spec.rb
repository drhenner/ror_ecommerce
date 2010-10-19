require "spec_helper"

describe Myaccount::OrdersController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/myaccount/orders" }.should route_to(:controller => "myaccount/orders", :action => "index")
    end

    it "recognizes and generates #show" do
      { :get => "/myaccount/orders/1" }.should route_to(:controller => "myaccount/orders", :action => "show", :id => "1")
    end

  end
end
