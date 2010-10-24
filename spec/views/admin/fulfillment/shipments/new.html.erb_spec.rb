require 'spec_helper'

describe "admin/fulfillment/shipments/new.html.erb" do
  before(:each) do
    @order = Factory(:order)
    @shipment = Factory(:shipment, :order => @order)
    #assign(:shipment, Factory.build(:shipment))
  end

  it "renders new shipment form" do
    render

  end
end
