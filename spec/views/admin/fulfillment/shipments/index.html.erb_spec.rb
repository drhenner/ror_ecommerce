require 'spec_helper'

describe "admin/fulfillment/shipments/index.html.erb" do
  before(:each) do
    assign(:shipments, [
      stub_model(Shipment,
        :tracking => "Tracking",
        :number => "Number",
        :state => "State"
      ),
      stub_model(Shipment,
        :tracking => "Tracking",
        :number => "Number",
        :state => "State"
      )
    ])
  end

  it "renders a list of shipments" do
    render
    
  end
end
