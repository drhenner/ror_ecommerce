require 'spec_helper'

describe "admin/history/addresses/new.html.erb" do
  before(:each) do
    @order = Factory(:order)
    @address = Factory.build(:address)
  end

  it "renders new address form" do
    render
  end
end
