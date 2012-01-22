require 'spec_helper'

describe "admin/fulfillment/orders/edit.html.erb" do
  before(:each) do
    @order = Factory(:order)
    #assign(:order, stub_model(Order,
    #  :new_record? => false,
    #  :email => "MyString",
    #  :name => "MyString"
    #))
  end

  it "renders the edit order form" do
    render :template => "admin/fulfillment/orders/edit", :handlers => [:erb]

  end
end
