require 'spec_helper'

describe "myaccount/orders/index.html.erb" do
  before(:each) do
    assign(:orders, [
      stub_model(Myaccount::Order,
        :number => "1"
      ),
      stub_model(Myaccount::Order,
        :number => "1"
      )
    ])
  end

  #it "renders a list of myaccount_orders" do
  #  render
  #  rendered.should have_selector("tr>td", :content => "Number".to_s, :count => 2)
  #end
end
