require 'spec_helper'

describe "admin/history/addresses/index.html.erb" do
  before(:each) do
    
    address = Factory(:address)
    @order = Factory(:order)
    assign(:addresses, [
      address,
      address
    ])
  end

  it "renders a list of addresses" do
    render
  end
end
