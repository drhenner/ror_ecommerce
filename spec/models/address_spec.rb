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
    puts @address2.address_type_id.to_s
    puts @address2.address_type_id.to_s
    @params2[:default] = '1'
    @address2.save_default_address(@user, @params2)
    @address.save_default_address(@user, @params)
    @address.default.should       be_true
    @address2.reload.default.should_not  be_true
  end
  
  
end