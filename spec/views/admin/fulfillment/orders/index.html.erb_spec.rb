require 'spec_helper'

describe "admin/fulfillment/orders/index.html.erb" do
  before(:each) do
    assign(:orders, [
      stub_model(Order,
        :email => "Email",
        :name => "Name"
      ),
      stub_model(Order,
        :email => "Email",
        :name => "Name"
      )
    ])
  end

  it "renders a list of orders" do
    render
    #rendered.should contain("Order".to_s)
  end
end
