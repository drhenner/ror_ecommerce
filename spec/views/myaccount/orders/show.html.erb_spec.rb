require 'spec_helper'

describe "myaccount_orders/show.html.erb" do
  before(:each) do
    @order = assign(:order, stub_model(Myaccount::Order,
      :number => "Number"
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should contain("Number".to_s)
  end
end
