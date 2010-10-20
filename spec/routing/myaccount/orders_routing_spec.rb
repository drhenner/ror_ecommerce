require "spec_helper"

describe Myaccount::OrdersController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/myaccount/orders" }.should route_to(:controller => "myaccount/orders", :action => "index")
    end

  end
end
