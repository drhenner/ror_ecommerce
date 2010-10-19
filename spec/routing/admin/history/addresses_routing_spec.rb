require "spec_helper"

describe Admin::History::AddressesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/admin/history/addresses" }.should route_to(:controller => "admin/history/addresses", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/admin/history/addresses/new" }.should route_to(:controller => "admin/history/addresses", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/admin/history/addresses/1" }.should route_to(:controller => "admin/history/addresses", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/admin/history/addresses/1/edit" }.should route_to(:controller => "admin/history/addresses", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/admin/history/addresses" }.should route_to(:controller => "admin/history/addresses", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/admin/history/addresses/1" }.should route_to(:controller => "admin/history/addresses", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/admin/history/addresses/1" }.should route_to(:controller => "admin/history/addresses", :action => "destroy", :id => "1")
    end

  end
end
