require 'spec_helper'

describe "admin/fulfillment/shipments/new.html.erb" do
  before(:each) do
    @order = Factory.build(:order)
    @shipment = Factory.build(:shipment, :order => @order)
    assign(:shipment, stub_model(Shipment,
      :new_record? => true,
      :tracking => "MyString",
      :number => "MyString",
      :state => "MyString"
    ))
  end

  it "renders new shipment form" do
    render

  end
end
