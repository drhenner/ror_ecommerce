require 'spec_helper'

describe "myaccount_orders/index.html.erb" do
  before(:each) do
    assign(:myaccount_orders, [
      stub_model(Myaccount::Order,
        :number => "Number"
      ),
      stub_model(Myaccount::Order,
        :number => "Number"
      )
    ])
  end

  it "renders a list of myaccount_orders" do
    render
    rendered.should have_selector("tr>td", :content => "Number".to_s, :count => 2)
  end
end
