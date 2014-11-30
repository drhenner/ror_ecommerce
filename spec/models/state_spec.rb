require 'spec_helper'

describe State, " methods" do
  before(:each) do
    @state ||= State.new( :abbreviation => 'CA', :name => 'California')
    #@mock_state.stub!(:abbreviation).and_return  'CA'
    #@mock_state.stub!(:name).and_return  'California'
  end

  context ".abbreviation_name(append_name = )" do

    it 'should return the correct string with no params' do
      expect(@state.abbreviation_name).to eq 'CA - California'
    end

    it 'should return the correct string with  params' do
      expect(@state.abbreviation_name('JJJ')).to eq 'CA - California JJJ'
    end
  end

  context ".abbrev_and_name" do
    it 'should return the correct string' do
      expect(@state.abbrev_and_name).to eq 'CA - California'
    end
  end
end

describe State, "class methods" do
  context "#form_selector" do
    it 'should return the correct objects' do
      @states = State.form_selector
      expect(@states.class).to              eq Array
      expect(@states.first.class).to        eq Array
      expect(@states.first.first.class).to  eq String
      expect(@states.first.last.class).to   eq Fixnum
    end
  end

  context 'all_with_country_id(country_id)' do
    before(:each) do
      @country = Country.find(Country::CANADA_ID)
      @states = State.all_with_country_id(@country.id)
    end

    it 'should return an array of States' do
      expect(@states.first.class).to        eq State
    end

    it 'should states with country id == country_id' do
      expect(@states.first.country_id).to eq @country.id
    end
  end
end
