require 'spec_helper'

describe "admin/history/addresses/show.html.erb" do
  before(:each) do
    @order = create(:order)
    @address =  create(:address)
  end

  it "renders attributes in <p>" do
    render :template => "admin/history/addresses/show", :handlers => [:erb]
  end
end
