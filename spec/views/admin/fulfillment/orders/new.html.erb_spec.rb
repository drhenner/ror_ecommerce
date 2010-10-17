require 'spec_helper'

describe "admin_fulfillment_orders/new.html.erb" do
  before(:each) do
    assign(:order, stub_model(Admin::Fulfillment::Order,
      :new_record? => true,
      :email => "MyString",
      :name => "MyString"
    ))
  end

  it "renders new order form" do
    render

    rendered.should have_selector("form", :action => admin_fulfillment_orders_path, :method => "post") do |form|
      form.should have_selector("input#order_email", :name => "order[email]")
      form.should have_selector("input#order_name", :name => "order[name]")
    end
  end
end
