require 'spec_helper'

describe "myaccount/orders/index.html.erb" do
  before(:each) do
    assign(:orders, [
      stub_model(Order,
        :number => "1"
      ),
      stub_model(Order,
        :number => "1"
      )
    ])
  end

  it "renders a list of myaccount_orders" do
    render
  end
end
