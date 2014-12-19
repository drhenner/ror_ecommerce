require "spec_helper"

describe Admin::Fulfillment::ShipmentsController do
  describe "routing" do

    it "recognizes and generates #index" do
      expect({ :get => "/admin/fulfillment/shipments" }).to route_to(:controller => "admin/fulfillment/shipments", :action => "index")
    end

    it "recognizes and generates #new" do
      expect({ :get => "/admin/fulfillment/shipments/new" }).to route_to(:controller => "admin/fulfillment/shipments", :action => "new")
    end

    it "recognizes and generates #show" do
      expect({ :get => "/admin/fulfillment/shipments/1" }).to route_to(:controller => "admin/fulfillment/shipments", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      expect({ :get => "/admin/fulfillment/shipments/1/edit" }).to route_to(:controller => "admin/fulfillment/shipments", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      expect({ :post => "/admin/fulfillment/shipments" }).to route_to(:controller => "admin/fulfillment/shipments", :action => "create")
    end

    it "recognizes and generates #update" do
      expect({ :put => "/admin/fulfillment/shipments/1" }).to route_to(:controller => "admin/fulfillment/shipments", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "/admin/fulfillment/shipments/1" }).to route_to(:controller => "admin/fulfillment/shipments", :action => "destroy", :id => "1")
    end

  end
end
