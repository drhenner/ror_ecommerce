require "spec_helper"

describe Admin::Rma::ReturnAuthorizationsController do
  describe "routing" do

    it "recognizes and generates #index" do
      expect({ :get => "/admin/rma/orders/11/return_authorizations" }).to route_to(:controller => "admin/rma/return_authorizations", :action => "index", :order_id => '11')
    end

    it "recognizes and generates #new" do
      expect({ :get => "/admin/rma/orders/11/return_authorizations/new" }).to route_to(:controller => "admin/rma/return_authorizations", :action => "new", :order_id => '11')
    end

    it "recognizes and generates #show" do
      expect({ :get => "/admin/rma/orders/11/return_authorizations/1" }).to route_to(:controller => "admin/rma/return_authorizations", :action => "show", :id => "1", :order_id => '11')
    end

    it "recognizes and generates #edit" do
      expect({ :get => "/admin/rma/orders/11/return_authorizations/1/edit" }).to route_to(:controller => "admin/rma/return_authorizations", :action => "edit", :id => "1", :order_id => '11')
    end

    it "recognizes and generates #create" do
      expect({ :post => "/admin/rma/orders/11/return_authorizations" }).to route_to(:controller => "admin/rma/return_authorizations", :action => "create", :order_id => '11')
    end

    it "recognizes and generates #update" do
      expect({ :put => "/admin/rma/orders/11/return_authorizations/1" }).to route_to(:controller => "admin/rma/return_authorizations", :action => "update", :id => "1", :order_id => '11')
    end

    it "recognizes and generates #destroy" do
      expect({ :delete => "/admin/rma/orders/11/return_authorizations/1" }).to route_to(:controller => "admin/rma/return_authorizations", :action => "destroy", :id => "1", :order_id => '11')
    end

  end
end
