require 'spec_helper'

describe "admin/fulfillment/shipments/edit.html.erb" do
  before(:each) do
    @shipment = Factory(:shipment)
    #assign(:shipment, stub_model(Shipment,
    #  :new_record? => false,
    #  :tracking => "MyString",
    #  :number => "MyString",
    #  :state => "MyString"
    #))
  end

  it "renders the edit shipment form" do
    render

  end
end
