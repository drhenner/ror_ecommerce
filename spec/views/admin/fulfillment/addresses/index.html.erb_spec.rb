require 'spec_helper'

describe "admin_fulfillment_addresses/index.html.erb" do
  before(:each) do
    assign(:addresses, [
      stub_model(Address),
      stub_model(Address)
    ])
  end

  it "renders a list of admin_fulfillment_addresses" do
    render
  end
end
