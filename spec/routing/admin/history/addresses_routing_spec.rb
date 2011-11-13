require "spec_helper"

describe Admin::History::AddressesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/admin/history/orders/11/addresses" }.should route_to(:controller => "admin/history/addresses", :action => "index", :order_id => '11')
    end

    it "recognizes and generates #new" do
      { :get => "/admin/history/orders/11/addresses/new" }.should route_to(:controller => "admin/history/addresses", :action => "new", :order_id => '11')
    end

    it "recognizes and generates #show" do
      { :get => "/admin/history/orders/11/addresses/1" }.should route_to(:controller => "admin/history/addresses", :action => "show", :id => "1", :order_id => '11')
    end

    it "recognizes and generates #edit" do
      { :get => "/admin/history/orders/11/addresses/1/edit" }.should route_to(:controller => "admin/history/addresses", :action => "edit", :id => "1", :order_id => '11')
    end

    it "recognizes and generates #create" do
      { :post => "/admin/history/orders/11/addresses" }.should route_to(:controller => "admin/history/addresses", :action => "create", :order_id => '11')
    end

    it "recognizes and generates #update" do
      { :put => "/admin/history/orders/11/addresses/1" }.should route_to(:controller => "admin/history/addresses", :action => "update", :id => "1", :order_id => '11')
    end
  end
end
