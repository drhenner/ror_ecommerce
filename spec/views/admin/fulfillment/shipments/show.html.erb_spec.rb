require 'spec_helper'

describe "admin/fulfillment/shipments/show.html.erb" do
  before(:each) do
    @shipment = Factory(:shipment)
  end

  it "renders attributes in <p>" do
    render :template => "admin/fulfillment/shipments/show", :handlers => [:erb]

  end
end
