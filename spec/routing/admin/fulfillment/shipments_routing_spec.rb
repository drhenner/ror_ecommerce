require "spec_helper"

describe Admin::Fulfillment::ShipmentsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/admin_fulfillment_shipments" }.should route_to(:controller => "admin_fulfillment_shipments", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/admin_fulfillment_shipments/new" }.should route_to(:controller => "admin_fulfillment_shipments", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/admin_fulfillment_shipments/1" }.should route_to(:controller => "admin_fulfillment_shipments", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/admin_fulfillment_shipments/1/edit" }.should route_to(:controller => "admin_fulfillment_shipments", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/admin_fulfillment_shipments" }.should route_to(:controller => "admin_fulfillment_shipments", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/admin_fulfillment_shipments/1" }.should route_to(:controller => "admin_fulfillment_shipments", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/admin_fulfillment_shipments/1" }.should route_to(:controller => "admin_fulfillment_shipments", :action => "destroy", :id => "1")
    end

  end
end
