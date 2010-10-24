require 'spec_helper'

describe "admin/fulfillment/shipments/index.html.erb" do
  before(:each) do
    ship = Factory(:shipment)
    @shipments = [
      ship,
      ship
    ]
  end

  it "renders a list of shipments" do
    render
    
  end
end
