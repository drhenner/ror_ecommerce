require 'spec_helper'

describe "admin_fulfillment_shipments/show.html.erb" do
  before(:each) do
    @shipment = assign(:shipment, stub_model(Admin::Fulfillment::Shipment,
      :tracking => "Tracking",
      :number => "Number",
      :state => "State"
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should contain("Tracking".to_s)
    rendered.should contain("Number".to_s)
    rendered.should contain("State".to_s)
  end
end
