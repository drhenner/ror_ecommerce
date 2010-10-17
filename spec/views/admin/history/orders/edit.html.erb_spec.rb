require 'spec_helper'

describe "admin_history_orders/edit.html.erb" do
  before(:each) do
    @order = assign(:order, stub_model(Admin::History::Order,
      :new_record? => false,
      :number => "MyString",
      :name => "MyString",
      :email => "MyString",
      :shipped => false
    ))
  end

  it "renders the edit order form" do
    render

    rendered.should have_selector("form", :action => order_path(@order), :method => "post") do |form|
      form.should have_selector("input#order_number", :name => "order[number]")
      form.should have_selector("input#order_name", :name => "order[name]")
      form.should have_selector("input#order_email", :name => "order[email]")
      form.should have_selector("input#order_shipped", :name => "order[shipped]")
    end
  end
end
