require 'spec_helper'

describe "admin/history/addresses/index.html.erb" do
  before(:each) do

    address = create(:address)
    @order = create(:order)
    @addresses = [
      address,
      address
    ]
  end

  it "renders a list of addresses" do
    render :template => "admin/history/addresses/index", :handlers => [:erb]
  end
end
