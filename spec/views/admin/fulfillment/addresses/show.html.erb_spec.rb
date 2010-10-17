require 'spec_helper'

describe "admin_fulfillment_addresses/show.html.erb" do
  before(:each) do
    @address = assign(:address, stub_model(Admin::Fulfillment::Address))
  end

  it "renders attributes in <p>" do
    render
  end
end
