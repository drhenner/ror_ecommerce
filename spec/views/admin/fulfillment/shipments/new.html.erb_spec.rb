require 'spec_helper'

describe "admin_fulfillment_shipments/new.html.erb" do
  before(:each) do
    assign(:shipment, stub_model(Admin::Fulfillment::Shipment,
      :new_record? => true,
      :tracking => "MyString",
      :number => "MyString",
      :state => "MyString"
    ))
  end

  it "renders new shipment form" do
    render

    rendered.should have_selector("form", :action => admin_fulfillment_shipments_path, :method => "post") do |form|
      form.should have_selector("input#shipment_tracking", :name => "shipment[tracking]")
      form.should have_selector("input#shipment_number", :name => "shipment[number]")
      form.should have_selector("input#shipment_state", :name => "shipment[state]")
    end
  end
end
