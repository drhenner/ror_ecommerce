require 'spec_helper'

describe "admin_fulfillment_orders/edit.html.erb" do
  before(:each) do
    @order = assign(:order, stub_model(Admin::Fulfillment::Order,
      :new_record? => false,
      :email => "MyString",
      :name => "MyString"
    ))
  end

  it "renders the edit order form" do
    render

    rendered.should have_selector("form", :action => order_path(@order), :method => "post") do |form|
      form.should have_selector("input#order_email", :name => "order[email]")
      form.should have_selector("input#order_name", :name => "order[name]")
    end
  end
end
