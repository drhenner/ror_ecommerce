require 'spec_helper'

describe "admin_fulfillment_orders/index.html.erb" do
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

  it "renders a list of admin_fulfillment_orders" do
    render
    rendered.should have_selector("tr>td", :content => "Email".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "Name".to_s, :count => 2)
  end
end
