require 'spec_helper'

describe "admin_history_addresses/new.html.erb" do
  before(:each) do
    assign(:address, stub_model(Admin::History::Address,
      :new_record? => true,
      :first_name => "MyString",
      :last_name => "MyString",
      :address1 => "MyString",
      :address2 => "MyString",
      :city => "MyString",
      :state_id => 1,
      :zip_code => "MyString"
    ))
  end

  it "renders new address form" do
    render

    rendered.should have_selector("form", :action => admin_history_addresses_path, :method => "post") do |form|
      form.should have_selector("input#address_first_name", :name => "address[first_name]")
      form.should have_selector("input#address_last_name", :name => "address[last_name]")
      form.should have_selector("input#address_address1", :name => "address[address1]")
      form.should have_selector("input#address_address2", :name => "address[address2]")
      form.should have_selector("input#address_city", :name => "address[city]")
      form.should have_selector("input#address_state_id", :name => "address[state_id]")
      form.should have_selector("input#address_zip_code", :name => "address[zip_code]")
    end
  end
end
