require 'spec_helper'

describe "admin_fulfillment_addresses/new.html.erb" do
  before(:each) do
    assign(:address, stub_model(Admin::Fulfillment::Address,
      :new_record? => true
    ))
  end

  it "renders new address form" do
    render

    rendered.should have_selector("form", :action => admin_fulfillment_addresses_path, :method => "post") do |form|
    end
  end
end
