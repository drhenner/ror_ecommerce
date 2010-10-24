require 'spec_helper'

describe "admin/rma/return_authorizations/show.html.erb" do
  before(:each) do
    @order = Factory(:order)
    @return_authorization = Factory(:return_authorization)
  end

  it "renders attributes in <p>" do
    render
  end
end
