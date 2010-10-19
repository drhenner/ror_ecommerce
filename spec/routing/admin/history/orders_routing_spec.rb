require "spec_helper"

describe Admin::History::OrdersController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/admin/history/orders" }.should route_to(:controller => "admin/history/orders", :action => "index")
    end
    
    it "recognizes and generates #show" do
      { :get => "/admin/history/orders/1" }.should route_to(:controller => "admin/history/orders", :action => "show", :id => "1")
    end

  end
end
