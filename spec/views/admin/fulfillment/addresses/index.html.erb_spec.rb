require 'spec_helper'

describe "admin_fulfillment_addresses/index.html.erb" do
  before(:each) do
    assign(:admin_fulfillment_addresses, [
      stub_model(Admin::Fulfillment::Address),
      stub_model(Admin::Fulfillment::Address)
    ])
  end

  it "renders a list of admin_fulfillment_addresses" do
    render
  end
end
