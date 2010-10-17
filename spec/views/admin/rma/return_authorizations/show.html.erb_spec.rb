require 'spec_helper'

describe "admin/rma/return_authorizations/show.html.erb" do
  before(:each) do
    @return_authorization = assign(:return_authorization, stub_model(ReturnAuthorization,
      :number => "Number",
      :amount => "9.99",
      :restocking_fee => "9.99",
      :order_id => 1,
      :state => "State",
      :created_by => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should contain("Number".to_s)
    rendered.should contain("9.99".to_s)
    rendered.should contain("9.99".to_s)
    rendered.should contain(1.to_s)
    rendered.should contain("State".to_s)
    rendered.should contain(1.to_s)
  end
end
