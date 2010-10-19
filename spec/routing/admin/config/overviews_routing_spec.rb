require "spec_helper"

describe Admin::Config::OverviewsController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/admin/config/overviews" }.should route_to(:controller => "admin/config/overviews", :action => "index")
    end

  end
end
