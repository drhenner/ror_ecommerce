require 'spec_helper'

describe "admin/history/orders/index.html.erb" do
  before(:each) do

    order = create(:order)
    @orders = [
      order,
      order
    ]
  end

  it "renders a list of orders" do
    render :template => "admin/history/orders/index", :handlers => [:erb]
  end
end
