require 'spec_helper'

describe "admin_fulfillment_orders/show.html.erb" do
  before(:each) do
    @order = assign(:order, stub_model(Admin::Fulfillment::Order,
      :email => "Email",
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should contain("Email".to_s)
    rendered.should contain("Name".to_s)
  end
end
