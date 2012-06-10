require 'spec_helper'

describe "admin/fulfillment/shipments/new.html.erb" do
  before(:each) do
    @order = FactoryGirl.create(:order)
    @shipment = FactoryGirl.create(:shipment, :order => @order)
    #assign(:shipment, FactoryGirl.build(:shipment))
  end

  it "renders new shipment form" do
    render :template => "admin/fulfillment/shipments/new", :handlers => [:erb]

  end
end
