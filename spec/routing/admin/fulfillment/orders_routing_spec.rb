require "spec_helper"

describe Admin::Fulfillment::OrdersController do
  describe "routing" do

    it "recognizes and generates #index" do
      expect({ :get => "/admin/fulfillment/orders" }).to route_to(:controller => "admin/fulfillment/orders", :action => "index")
    end

    it "recognizes and generates #show" do
      expect({ :get => "/admin/fulfillment/orders/1" }).to route_to(:controller => "admin/fulfillment/orders", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "/admin/fulfillment/orders/1/edit" }).to route_to(:controller => "admin/fulfillment/orders", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "/admin/fulfillment/orders" }).to route_to(:controller => "admin/fulfillment/orders", :action => "create")
    end

    it "recognizes and generates #update" do
      expect({ :put => "/admin/fulfillment/orders/1" }).to route_to(:controller => "admin/fulfillment/orders", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "/admin/fulfillment/orders/1" }).to route_to(:controller => "admin/fulfillment/orders", :action => "destroy", :id => "1")
    end

  end
end
