require "spec_helper"

describe Admin::Fulfillment::OrdersController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/admin_fulfillment_orders" }.should route_to(:controller => "admin_fulfillment_orders", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/admin_fulfillment_orders/new" }.should route_to(:controller => "admin_fulfillment_orders", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/admin_fulfillment_orders/1" }.should route_to(:controller => "admin_fulfillment_orders", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/admin_fulfillment_orders/1/edit" }.should route_to(:controller => "admin_fulfillment_orders", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/admin_fulfillment_orders" }.should route_to(:controller => "admin_fulfillment_orders", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/admin_fulfillment_orders/1" }.should route_to(:controller => "admin_fulfillment_orders", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/admin_fulfillment_orders/1" }.should route_to(:controller => "admin_fulfillment_orders", :action => "destroy", :id => "1")
    end

  end
end
