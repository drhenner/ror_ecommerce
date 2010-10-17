require 'spec_helper'

describe "admin_fulfillment_addresses/edit.html.erb" do
  before(:each) do
    @address = assign(:address, stub_model(Admin::Fulfillment::Address,
      :new_record? => false
    ))
  end

  it "renders the edit address form" do
    render

    rendered.should have_selector("form", :action => address_path(@address), :method => "post") do |form|
    end
  end
end
