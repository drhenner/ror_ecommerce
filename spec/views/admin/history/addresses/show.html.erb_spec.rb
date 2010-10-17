require 'spec_helper'

describe "admin_history_addresses/show.html.erb" do
  before(:each) do
    @address = assign(:address, stub_model(Admin::History::Address,
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
    rendered.should contain("First Name".to_s)
    rendered.should contain("Last Name".to_s)
    rendered.should contain("Address1".to_s)
    rendered.should contain("Address2".to_s)
    rendered.should contain("City".to_s)
    rendered.should contain(1.to_s)
    rendered.should contain("Zip Code".to_s)
  end
end
