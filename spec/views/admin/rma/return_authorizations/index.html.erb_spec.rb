require 'spec_helper'

describe "admin/rma/return_authorizations/index.html.erb" do
  before(:each) do
    @order = Factory(:order)
    assign(:return_authorizations, [
      stub_model(ReturnAuthorization,
        :number => "Number",
        :amount => "9.99",
        :restocking_fee => "9.99",
        :order_id => 1,
        :state => "State",
        :created_by => 1
      ),
      stub_model(ReturnAuthorization,
        :number => "Number",
        :amount => "9.99",
        :restocking_fee => "9.99",
        :order_id => 1,
        :state => "State",
        :created_by => 1
      )
    ])
  end

  it "renders a list of return_authorizations" do
    render
  end
end
