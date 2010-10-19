require 'spec_helper'

describe "myaccount_orders/show.html.erb" do
  before(:each) do
    @order = assign(:order, stub_model(Myaccount::Order,
      :number => "12"
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should contain("12".to_s)
  end
end
