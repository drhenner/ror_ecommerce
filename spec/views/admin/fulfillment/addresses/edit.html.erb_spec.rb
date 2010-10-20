require 'spec_helper'

describe "admin/fulfillment/addresses/edit.html.erb" do
  before(:each) do
    @address = assign(:address, stub_model(Address,
      :new_record?  => false,
      :address1     => "address1",
      :city         => "city"
    ))
    @addresses = assign(:addresses, [
      stub_model(Address,
        :address1 => "address1",
        :city     => "city"
      ),
      stub_model(Address,
        :address1 => "address1",
        :city     => "City"
      )
    ])
    @shipment = assign(:shipment, stub_model(Shipment,
      :number   => 'BLAHnumber'
    ))
  end

  it "renders the edit address form" do
    render
    #admin_fulfillment_shipment_address_path(@shipment, address)
    #rendered.should have_selector("form", :action => admin_fulfillment_address_path(@address), :method => "post") do |form|
    #end
  end
end
