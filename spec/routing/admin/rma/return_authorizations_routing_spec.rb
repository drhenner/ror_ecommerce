require "spec_helper"

describe Admin::Rma::ReturnAuthorizationsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/admin/rma/return_authorizations" }.should route_to(:controller => "admin/rma/return_authorizations", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/admin/rma/return_authorizations/new" }.should route_to(:controller => "admin/rma/return_authorizations", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/admin/rma/return_authorizations/1" }.should route_to(:controller => "admin/rma/return_authorizations", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/admin/rma/return_authorizations/1/edit" }.should route_to(:controller => "admin/rma/return_authorizations", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/admin/rma/return_authorizations" }.should route_to(:controller => "admin/rma/return_authorizations", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/admin/rma/return_authorizations/1" }.should route_to(:controller => "admin/rma/return_authorizations", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/admin/rma/return_authorizations/1" }.should route_to(:controller => "admin/rma/return_authorizations", :action => "destroy", :id => "1")
    end

  end
end
