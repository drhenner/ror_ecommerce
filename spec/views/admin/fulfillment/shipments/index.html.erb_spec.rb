require 'spec_helper'

describe "admin_fulfillment_shipments/index.html.erb" do
  before(:each) do
    assign(:admin_fulfillment_shipments, [
      stub_model(Admin::Fulfillment::Shipment,
        :tracking => "Tracking",
        :number => "Number",
        :state => "State"
      ),
      stub_model(Admin::Fulfillment::Shipment,
        :tracking => "Tracking",
        :number => "Number",
        :state => "State"
      )
    ])
  end

  it "renders a list of admin_fulfillment_shipments" do
    render
    rendered.should have_selector("tr>td", :content => "Tracking".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "Number".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "State".to_s, :count => 2)
  end
end
