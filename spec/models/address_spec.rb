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


describe Address, ".name" do
  
  it 'should return the correct string with no params' do
    address = Address.new( :first_name => 'Perez', :last_name => 'Hilton')
    address.name.should == 'Perez Hilton'
  end
end

describe Address, ".inactive!" do
  pending "test for inactive!"
end

describe Address, ".address_atributes" do
  pending "test for address_atributes"
end

describe Address, ".cc_params" do
  pending "test for cc_params"
end

describe Address, "#update_address" do
  pending "test for Address.update_address(old_address, params, address_type_id = AddressType::SHIPPING_ID )"
end

describe Address, ".address_lines" do
  pending "test for address_lines"
end

describe Address, ".state_abbr_name" do
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
