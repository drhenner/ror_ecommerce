require 'spec_helper'

describe "admin_history_addresses/index.html.erb" do
  before(:each) do
    assign(:addresses, [
      stub_model(Address,
        :first_name => "First Name",
        :last_name => "Last Name",
        :address1 => "Address1",
        :address2 => "Address2",
        :city => "City",
        :state_id => 1,
        :zip_code => "Zip Code"
      ),
      stub_model(Address,
        :first_name => "First Name",
        :last_name => "Last Name",
        :address1 => "Address1",
        :address2 => "Address2",
        :city => "City",
        :state_id => 1,
        :zip_code => "Zip Code"
      )
    ])
  end

  it "renders a list of admin_history_addresses" do
    render
    rendered.should have_selector("tr>td", :content => "First Name".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "Last Name".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "Address1".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "Address2".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "City".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => 1.to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "Zip Code".to_s, :count => 2)
  end
end
