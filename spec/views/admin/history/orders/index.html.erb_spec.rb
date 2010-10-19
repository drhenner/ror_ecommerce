require 'spec_helper'

describe "admin_history_orders/index.html.erb" do
  before(:each) do
    assign(:orders, [
      stub_model(Order,
        :number => "Number",
        :name => "Name",
        :email => "Email",
        :shipped => false
      ),
      stub_model(Order,
        :number => "Number",
        :name => "Name",
        :email => "Email",
        :shipped => false
      )
    ])
  end

  it "renders a list of admin_history_orders" do
    render
    rendered.should have_selector("tr>td", :content => "Number".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "Name".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "Email".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => false.to_s, :count => 2)
  end
end
