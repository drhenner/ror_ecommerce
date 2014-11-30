require "spec_helper"

describe Admin::History::AddressesController do
  describe "routing" do

    it "recognizes and generates #index" do
      expect({ :get => "/admin/history/orders/11/addresses" }).to route_to(:controller => "admin/history/addresses", :action => "index", :order_id => '11')
    end

    it "recognizes and generates #new" do
      expect({ :get => "/admin/history/orders/11/addresses/new" }).to route_to(:controller => "admin/history/addresses", :action => "new", :order_id => '11')
    end

    it "recognizes and generates #show" do
      expect({ :get => "/admin/history/orders/11/addresses/1" }).to route_to(:controller => "admin/history/addresses", :action => "show", :id => "1", :order_id => '11')
    end

    it "recognizes and generates #edit" do
      expect({ :get => "/admin/history/orders/11/addresses/1/edit" }).to route_to(:controller => "admin/history/addresses", :action => "edit", :id => "1", :order_id => '11')
    end

    it "recognizes and generates #create" do
      expect({ :post => "/admin/history/orders/11/addresses" }).to route_to(:controller => "admin/history/addresses", :action => "create", :order_id => '11')
    end

    it "recognizes and generates #update" do
      expect({ :put => "/admin/history/orders/11/addresses/1" }).to route_to(:controller => "admin/history/addresses", :action => "update", :id => "1", :order_id => '11')
    end
  end
end
