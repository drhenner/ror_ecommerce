require 'spec_helper'

describe "admin/history/addresses/new.html.erb" do
  before(:each) do
    @order = Factory(:order)
    assign(:address, stub_model(Address,
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
  end
end
