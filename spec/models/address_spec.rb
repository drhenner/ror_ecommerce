require 'spec_helper'

describe Address do
  context "Valid Address" do
    before(:each) do
      User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
      @address = build(:address)
    end

    it "should be valid with minimum attribues" do
      expect(@address).to be_valid
    end
  end
end

describe Address, "methods" do
  before(:each) do
    User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
    state = State.find_by_abbreviation('CA')
    @user = FactoryGirl.create(:user)
    @address = @user.addresses.new(:first_name => 'Perez',
                          :last_name  => 'Hilton',
                          :address1   => '7th street',
                          :city       => 'Fredville',
                          :state   => state,
                          :state_name => 'CA',
                          :zip_code   => '13156',
                          :address_type_id  => 1#,
                          #:addressable_type => 'User',
                          #:addressable_id   => 1,
                          #:active           => true
                          )
  end

  context ".name" do
    it 'should return the correct string with no params' do
      expect(@address.name).to eq 'Perez Hilton'
    end
  end

  context ".inactive!" do
    it 'should inactivate the address' do
      @address.save
      @address.inactive!
      expect(@address.active).to be false
    end
  end

  context ".address_attributes" do
    #attributes.delete_if {|key, value| ["id", 'updated_at', 'created_at'].any?{|k| k == key }}
    it 'should return all the address attributes except id, updated and created_at' do
      @address.save
      attributes = @address.address_attributes
      expect(attributes['id']).to be_nil
      expect(attributes['created_at']).to be_nil
      expect(attributes['updated_at']).to be_nil
      expect(attributes['first_name']).to eq 'Perez'
    end
  end

  context ".cc_params" do
    it 'should return the params needed by the credit card vaults' do
      cc_params = @address.cc_params
      expect(cc_params[:name]).to    eq 'Perez Hilton'
      expect(cc_params[:address1]).to eq '7th street'
      expect(cc_params[:city]).to    eq 'Fredville'
      expect(cc_params[:state]).to   eq 'CA'
      expect(cc_params[:zip]).to     eq '13156'
      expect(cc_params[:country]).to eq 'US'


    end
  end

  context '.full_address_array' do
    it 'should return an array of address lines and name' do
      expect(@address.full_address_array).to eq ['Perez Hilton','7th street','Fredville, CA 13156']
    end
  end

  context ".address_lines" do
    # def address_lines(join_chars = ', ')
    # [address1, address2].delete_if{|add| add.blank?}.join(join_chars)
    it 'should display the address lines' do
      expect(@address.address_lines).to eq '7th street'
      @address.address2 = 'test'
      expect(@address.address_lines).to eq '7th street, test'
      expect(@address.address_lines(' H ')).to eq '7th street H test'
    end
  end

  context ".state_abbr_name" do
    it 'should display the state_abbr_name' do
      expect(@address.state_abbr_name).to eq @address.state.abbreviation
    end
  end

  context ".shipping_method_ids" do
    it 'should be the state\'s shipping methods' do
      Settings.require_state_in_address = true
      shipping_zone = ShippingZone.find(1)
      shipping_zone.stubs(:shipping_method_ids).returns([2,4])
      state = State.first
      state.stubs(:shipping_zone).returns(shipping_zone)
      address = FactoryGirl.create(:address, :state => state)
      expect(address.shipping_method_ids).to eq [2,4]
    end

    it 'should be the countries\'s shipping methods' do
      @finland = Country.find(67)
      @finland.shipping_zone_id = 2
      @finland.save
      Settings.stubs(:require_state_in_address).returns(false)# = true
      shipping_zone = ShippingZone.find(1)
      shipping_zone.stubs(:shipping_method_ids).returns([2,3])
      @finland.stubs(:shipping_zone).returns(shipping_zone)
      address = FactoryGirl.create(:address, :country => @finland, :state => nil)
      expect(address.shipping_method_ids).to eq [2,3]
      Settings.require_state_in_address = true
    end
  end

  describe Address, ".city_state_name" do
    #[city, state_abbr_name].join(', ')
    it 'should display the state_abbr_name' do
      expect(@address.city_state_name).to eq "Fredville, #{@address.state.abbreviation}"
    end
  end

  describe Address, ".city_state_zip" do
    #[city_state_name, zip_code].join(' ')
    it 'should display the city_state_zip' do
      expect(@address.city_state_zip).to eq "Fredville, #{@address.state.abbreviation} 13156"
    end
  end

  describe Address, ".sanitize_data" do
    address = Address.new(:first_name => ' Perez ',
                          :last_name  => ' Hilton ',
                          :address1   => ' 1st street ',
                          :address2   => ' 2nd street ',
                          :city       => ' Fredville ',
                          :state_name => 'CA',
                          :zip_code   => ' 13156 ',
                          :address_type_id  => 1#,
                          #:addressable_type => 'User',
                          #:addressable_id   => 1,
                          #:active           => true
                          )
    it 'should sanitize_data' do
      address.send(:sanitize_data)
      expect(address.first_name).to eq  'Perez'
      expect(address.last_name).to  eq  'Hilton'
      expect(address.city).to       eq  'Fredville'
      expect(address.zip_code).to   eq  '13156'
      expect(address.address1).to   eq  '1st street'
      expect(address.address2).to   eq  '2nd street'
    end
  end
end

# Save method should save to default address attribute and make all other default addresses "not default" for that user
describe Address, "#save" do

  before(:each) do
    @user     = FactoryGirl.create(:user)
    @address  = FactoryGirl.create(:address, addressable: @user)
  end

  it "should only the last default address should be the default address" do
    @address3   = FactoryGirl.create(:address)
    @address3.default = true
    @address3.save
    @address2   = FactoryGirl.create(:address, :addressable => @user)
    @address2.default = true
    @address2.save
    @address.default = true
    @address.save
    expect(@address.default).to       be true
    expect(@address2.reload.default).not_to  be true
    expect(@address3.reload.default).to  be true # should only update the addresses that belong to that user
  end
end

describe Address do
  describe "before save" do
    it "#invalidates_old_defaults" do
      old_address = FactoryGirl.create(:address, default: true, billing_default: true)
      new_address = old_address.dup
      new_address.save
      old_address.reload
      expect(old_address).not_to be_default
      expect(old_address).not_to be_billing_default
    end

    context "when #replace_address_id is set" do
      it "replaces the address" do
        old_address = FactoryGirl.create(:address)
        expect(old_address).to be_active
        new_address = old_address.dup
        new_address.replace_address_id = old_address.id
        new_address.save
        old_address.reload
        expect(old_address).not_to be_active
      end
    end
  end
end
