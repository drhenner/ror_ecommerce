require "spec_helper"

describe Admin::Config::OverviewsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/admin_config_overviews" }.should route_to(:controller => "admin_config_overviews", :action => "index")
    end

  end
end
