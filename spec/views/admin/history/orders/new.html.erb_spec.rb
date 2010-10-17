require 'spec_helper'

describe "admin_history_orders/new.html.erb" do
  before(:each) do
    assign(:order, stub_model(Admin::History::Order,
      :new_record? => true,
      :number => "MyString",
      :name => "MyString",
      :email => "MyString",
      :shipped => false
    ))
  end

  it "renders new order form" do
    render

    rendered.should have_selector("form", :action => admin_history_orders_path, :method => "post") do |form|
      form.should have_selector("input#order_number", :name => "order[number]")
      form.should have_selector("input#order_name", :name => "order[name]")
      form.should have_selector("input#order_email", :name => "order[email]")
      form.should have_selector("input#order_shipped", :name => "order[shipped]")
    end
  end
end
