require "spec_helper"

describe Admin::Fulfillment::AddressesController do
  describe "routing" do

    it "recognizes and generates #edit" do
      expect({ :get => "/admin/fulfillment/shipments/11/addresses/1/edit" }).to route_to(:controller => "admin/fulfillment/addresses", :action => "edit", :id => "1", :shipment_id => '11')
    end

    it "recognizes and generates #update" do
      expect({ :put => "/admin/fulfillment/shipments/11/addresses/1" }).to route_to(:controller => "admin/fulfillment/addresses", :action => "update", :id => "1", :shipment_id => '11')
    end

  end
end
