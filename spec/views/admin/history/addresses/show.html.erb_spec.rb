require 'spec_helper'

describe "admin/history/addresses/show.html.erb" do
  before(:each) do
    @order = Factory(:order)
    @address = assign(:address, stub_model(Address,
      :first_name => "First Name",
      :last_name => "Last Name",
      :address1 => "Address1",
      :address2 => "Address2",
      :city => "City",
      :state_id => 1,
      :zip_code => "Zip Code"
    ))
  end

  it "renders attributes in <p>" do
    render
  end
end
