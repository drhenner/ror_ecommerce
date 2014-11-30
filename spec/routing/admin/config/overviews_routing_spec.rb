require "spec_helper"

describe Admin::Config::OverviewsController do
  describe "routing" do

    it "recognizes and generates #index" do
      expect({ :get => "/admin/config/overviews" }).to route_to(:controller => "admin/config/overviews", :action => "index")
    end

  end
end
