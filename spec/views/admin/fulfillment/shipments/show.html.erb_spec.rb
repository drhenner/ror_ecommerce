require 'spec_helper'

describe "admin/fulfillment/shipments/show.html.erb" do
  before(:each) do
    @shipment = assign(:shipment, stub_model(Shipment,
      :tracking => "Tracking",
      :number => "Number",
      :state => "State"
    ))
  end

  it "renders attributes in <p>" do
    render
    
  end
end
