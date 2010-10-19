require "spec_helper"

describe Admin::Fulfillment::ShipmentsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/admin/fulfillment/shipments" }.should route_to(:controller => "admin/fulfillment/shipments", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/admin/fulfillment/shipments/new" }.should route_to(:controller => "admin/fulfillment/shipments", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/admin/fulfillment/shipments/1" }.should route_to(:controller => "admin/fulfillment/shipments", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/admin/fulfillment/shipments/1/edit" }.should route_to(:controller => "admin/fulfillment/shipments", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/admin/fulfillment/shipments" }.should route_to(:controller => "admin/fulfillment/shipments", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/admin/fulfillment/shipments/1" }.should route_to(:controller => "admin/fulfillment/shipments", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/admin/fulfillment/shipments/1" }.should route_to(:controller => "admin/fulfillment/shipments", :action => "destroy", :id => "1")
    end

  end
end
