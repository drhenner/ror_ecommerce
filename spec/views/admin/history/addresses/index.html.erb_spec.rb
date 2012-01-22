require 'spec_helper'

describe "admin/history/addresses/index.html.erb" do
  before(:each) do

    address = Factory(:address)
    @order = Factory(:order)
    @addresses = [
      address,
      address
    ]
  end

  it "renders a list of addresses" do
    render :template => "admin/history/addresses/index", :handlers => [:erb]
  end
end
