require 'spec_helper'

describe "myaccount_orders/new.html.erb" do
  before(:each) do
    assign(:order, stub_model(Myaccount::Order,
      :new_record? => true,
      :number => "MyString"
    ))
  end

  it "renders new order form" do
    render

    rendered.should have_selector("form", :action => myaccount_orders_path, :method => "post") do |form|
      form.should have_selector("input#order_number", :name => "order[number]")
    end
  end
end
