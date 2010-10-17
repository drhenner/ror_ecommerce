require "spec_helper"

describe Admin::Config::OverviewsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/admin_config_overviews" }.should route_to(:controller => "admin_config_overviews", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/admin_config_overviews/new" }.should route_to(:controller => "admin_config_overviews", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/admin_config_overviews/1" }.should route_to(:controller => "admin_config_overviews", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/admin_config_overviews/1/edit" }.should route_to(:controller => "admin_config_overviews", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/admin_config_overviews" }.should route_to(:controller => "admin_config_overviews", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/admin_config_overviews/1" }.should route_to(:controller => "admin_config_overviews", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/admin_config_overviews/1" }.should route_to(:controller => "admin_config_overviews", :action => "destroy", :id => "1")
    end

  end
end
