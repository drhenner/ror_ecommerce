require 'spec_helper'

describe "myaccount_orders/edit.html.erb" do
  before(:each) do
    @order = assign(:order, stub_model(Myaccount::Order,
      :new_record? => false,
      :number => "MyString"
    ))
  end

  it "renders the edit order form" do
    render

    rendered.should have_selector("form", :action => order_path(@order), :method => "post") do |form|
      form.should have_selector("input#order_number", :name => "order[number]")
    end
  end
end
