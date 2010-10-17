require "spec_helper"

describe Myaccount::OrdersController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/myaccount_orders" }.should route_to(:controller => "myaccount_orders", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/myaccount_orders/new" }.should route_to(:controller => "myaccount_orders", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/myaccount_orders/1" }.should route_to(:controller => "myaccount_orders", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/myaccount_orders/1/edit" }.should route_to(:controller => "myaccount_orders", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/myaccount_orders" }.should route_to(:controller => "myaccount_orders", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/myaccount_orders/1" }.should route_to(:controller => "myaccount_orders", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/myaccount_orders/1" }.should route_to(:controller => "myaccount_orders", :action => "destroy", :id => "1")
    end

  end
end
