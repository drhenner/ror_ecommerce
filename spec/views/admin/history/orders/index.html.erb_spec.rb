require 'spec_helper'

describe "admin/history/orders/index.html.erb" do
  before(:each) do
    
    order = Factory(:order)
    @orders = [
      order,
      order
    ]
  end

  it "renders a list of orders" do
    render
  end
end
