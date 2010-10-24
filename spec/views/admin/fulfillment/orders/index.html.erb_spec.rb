require 'spec_helper'

describe "admin/fulfillment/orders/index.html.erb" do
  before(:each) do
    @orders = [
      Factory(:order),
      Factory(:order)
    ]
  end

  it "renders a list of orders" do
    render
    #rendered.should contain("Order".to_s)
  end
end
