require "spec_helper"

describe Admin::Fulfillment::OrdersController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/admin/fulfillment/orders" }.should route_to(:controller => "admin/fulfillment/orders", :action => "index")
    end

    it "recognizes and generates #show" do
      { :get => "/admin/fulfillment/orders/1" }.should route_to(:controller => "admin/fulfillment/orders", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/admin/fulfillment/orders/1/edit" }.should route_to(:controller => "admin/fulfillment/orders", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/admin/fulfillment/orders" }.should route_to(:controller => "admin/fulfillment/orders", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/admin/fulfillment/orders/1" }.should route_to(:controller => "admin/fulfillment/orders", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/admin/fulfillment/orders/1" }.should route_to(:controller => "admin/fulfillment/orders", :action => "destroy", :id => "1")
    end

  end
end
