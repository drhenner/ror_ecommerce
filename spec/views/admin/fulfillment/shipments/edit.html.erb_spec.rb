require 'spec_helper'

describe "admin_fulfillment_shipments/edit.html.erb" do
  before(:each) do
    @shipment = assign(:shipment, stub_model(Admin::Fulfillment::Shipment,
      :new_record? => false,
      :tracking => "MyString",
      :number => "MyString",
      :state => "MyString"
    ))
  end

  it "renders the edit shipment form" do
    render

    rendered.should have_selector("form", :action => shipment_path(@shipment), :method => "post") do |form|
      form.should have_selector("input#shipment_tracking", :name => "shipment[tracking]")
      form.should have_selector("input#shipment_number", :name => "shipment[number]")
      form.should have_selector("input#shipment_state", :name => "shipment[state]")
    end
  end
end
