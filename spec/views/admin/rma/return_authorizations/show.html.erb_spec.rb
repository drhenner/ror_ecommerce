require 'spec_helper'

describe "admin/rma/return_authorizations/show.html.erb" do
  before(:each) do
    @order = Factory(:order)
    @return_authorization = Factory(:return_authorization)
    assign(:return_authorization, stub_model(ReturnAuthorization,
      :number => "Number",
      :amount => "9.99",
      :restocking_fee => "9.97",
      :order_id => 1,
      :state => "State",
      :created_by => 1
    ))
  end

  it "renders attributes in <p>" do
    render
  end
end
