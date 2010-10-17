require 'spec_helper'

describe "admin_history_orders/show.html.erb" do
  before(:each) do
    @order = assign(:order, stub_model(Admin::History::Order,
      :number => "Number",
      :name => "Name",
      :email => "Email",
      :shipped => false
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should contain("Number".to_s)
    rendered.should contain("Name".to_s)
    rendered.should contain("Email".to_s)
    rendered.should contain(false.to_s)
  end
end
