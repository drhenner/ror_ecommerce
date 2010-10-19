require "spec_helper"

describe Admin::Fulfillment::AddressesController do
  describe "routing" do

    it "recognizes and generates #edit" do
      { :get => "/admin/fulfillment/shipments/11/addresses/1/edit" }.should route_to(:controller => "admin/fulfillment/addresses", :action => "edit", :id => "1", :shipment_id => '11')
    end

    it "recognizes and generates #update" do
      { :put => "/admin/fulfillment/shipments/11/addresses/1" }.should route_to(:controller => "admin/fulfillment/addresses", :action => "update", :id => "1", :shipment_id => '11')
    end

  end
end
