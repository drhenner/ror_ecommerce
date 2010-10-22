require 'spec_helper'

describe Address do
  context "Valid Address" do
    before(:each) do
      @address = Factory.build(:address)
    end
    
    it "should be valid with minimum attribues" do
      @address.should be_valid
    end
    
  end
  
end

describe Address, "methods" do
  before(:each) do
    state = State.find_by_abbreviation('CA')
    @address = Address.new(:first_name => 'Perez', 
                          :last_name  => 'Hilton',
                          :address1   => '7th street',
                          :city       => 'Fredville',
                          :state   => state,
                          :zip_code   => '13156',
                          :address_type_id  => 1,
                          :addressable_type => 'User',
                          :addressable_id   => 1,
                          :active           => true
                          )
  end
  
  context ".name" do
    it 'should return the correct string with no params' do
      @address.name.should == 'Perez Hilton'
    end
  end

  context ".inactive!" do
    it 'should inactivate the address' do
      @address.save
      puts @address.inactive!
      @address.active.should be_false
    end
  end

  context ".address_attributes" do
    #attributes.delete_if {|key, value| ["id", 'updated_at', 'created_at'].any?{|k| k == key }}
    it 'should return all the address attributes except id, updated and created_at' do
      @address.save
      attributes = @address.address_attributes
      attributes['id'].should be_nil
      attributes['created_at'].should be_nil
      attributes['updated_at'].should be_nil
      attributes['first_name'].should == 'Perez'
    end
  end

  context ".cc_params" do
    it 'should return the params needed by the credit card vaults' do
      cc_params = @address.cc_params
      cc_params[:name].should    == 'Perez Hilton'
      cc_params[:address1].should == '7th street'
      cc_params[:city].should    == 'Fredville'
      cc_params[:state].should   == 'CA'
      cc_params[:zip].should     == '13156'
      cc_params[:country].should == 'US'

      
    end
  end

  context "#update_address" do
    pending "test for Address.update_address(old_address, params, address_type_id = AddressType::SHIPPING_ID )"
  end

  context ".address_lines" do
    pending "test for address_lines"
  end

  context ".state_abbr_name" do
    pending "test for state_abbr_name"
  end

  describe Address, ".city_state_name" do
    pending "test for city_state_name"
  end

  describe Address, ".city_state_zip" do
    pending "test for city_state_zip"
  end

  describe Address, ".sanitize_data" do
    pending "test for sanitize_data"
  end
end

describe Address, "#save_default_address(object, params)" do
  
  before(:each) do
    @user     = Factory.create(:user)
    @address  = Factory.create(:address)
    @params   = @address.attributes
    @params[:default] = '1'
  end
  
  it "should save the address" do
    @address.save_default_address(@user, @params)
    @address.id.should_not be_nil
  end
  
  it "should only the last default address should be the default address" do
    
    @address2   = Factory.create(:address)
    @params2    = Factory.create(:address).attributes
    #puts @address2.address_type_id.to_s
    @params2[:default] = '1'
    @address2.save_default_address(@user, @params2)
    @address.save_default_address(@user, @params)
    @address.default.should       be_true
    @address2.reload.default.should_not  be_true
  end
  
  
end
