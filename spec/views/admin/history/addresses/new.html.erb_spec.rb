require 'spec_helper'

describe "admin/history/addresses/new.html.erb" do
  before(:each) do
    @order = create(:order)
    @address = build(:address)
    view.stubs(:states).returns([])
  end

  it "renders new address form" do
    render :template => "admin/history/addresses/new", :handlers => [:erb]
  end
end
