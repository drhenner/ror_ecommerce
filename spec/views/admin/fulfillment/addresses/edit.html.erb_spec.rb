require 'spec_helper'

describe "admin/fulfillment/addresses/edit.html.erb" do
  before(:each) do
    @address = create(:address)
    @addresses =  [
      create(:address),
      create(:address)
    ]
    @shipment = create(:shipment)
  end

  it "renders the edit address form" do
    render :template => "admin/fulfillment/addresses/edit", :handlers => [:erb]
    #admin_fulfillment_shipment_address_path(@shipment, address)
    #rendered.should have_selector("form", :action => admin_fulfillment_address_path(@address), :method => "post") do |form|
    #end
  end
end
