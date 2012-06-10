require 'spec_helper'

describe "admin/fulfillment/shipments/index.html.erb" do
  before(:each) do
    ship = create(:shipment)
    @shipments = [
      ship,
      ship
    ]
  end

  it "renders a list of shipments" do
    render :template => "admin/fulfillment/shipments/index", :handlers => [:erb]

  end
end
