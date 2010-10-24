require 'spec_helper'

describe "admin/rma/return_authorizations/index.html.erb" do
  before(:each) do
    @order = Factory(:order)
    @return_authorizations = [
      Factory(:return_authorization),
      Factory(:return_authorization)
    ]
  end

  it "renders a list of return_authorizations" do
    render
  end
end
