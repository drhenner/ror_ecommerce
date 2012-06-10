require 'spec_helper'

describe "admin/history/addresses/edit.html.erb" do
  before(:each) do
    @order = create(:order)
    @address = create(:address)
    view.stubs(:states).returns([])
  #  assign(:address, stub_model(Address,
  #    :new_record? => false,
  #    :first_name => "MyString",
  #    :last_name => "MyString",
  #    :address1 => "MyString",
  #    :address2 => "MyString",
  #    :city => "MyString",
  #    :state_id => 1,
  #    :zip_code => "MyString"
  #  ))
  end

  it "renders the edit address form" do
    render :template => "admin/history/addresses/edit", :handlers => [:erb]
  end
end
