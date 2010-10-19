require "spec_helper"

describe Admin::Fulfillment::AddressesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/admin/fulfillment/addresses" }.should route_to(:controller => "admin/fulfillment/addresses", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/admin/fulfillment/addresses/new" }.should route_to(:controller => "admin/fulfillment/addresses", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/admin/fulfillment/addresses/1" }.should route_to(:controller => "admin/fulfillment/addresses", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/admin/fulfillment/addresses/1/edit" }.should route_to(:controller => "admin/fulfillment/addresses", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/admin/fulfillment/addresses" }.should route_to(:controller => "admin/fulfillment/addresses", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/admin/fulfillment/addresses/1" }.should route_to(:controller => "admin/fulfillment/addresses", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/admin/fulfillment/addresses/1" }.should route_to(:controller => "admin/fulfillment/addresses", :action => "destroy", :id => "1")
    end

  end
end
