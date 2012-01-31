require 'spec_helper'

describe State, " methods" do
  before(:each) do
    @state ||= State.new( :abbreviation => 'CA', :name => 'California')
    #@mock_state.stub!(:abbreviation).and_return  'CA'
    #@mock_state.stub!(:name).and_return  'California'
  end

  context ".abbreviation_name(append_name = )" do

    it 'should return the correct string with no params' do
      @state.abbreviation_name.should == 'CA - California'
    end

    it 'should return the correct string with  params' do
      @state.abbreviation_name('JJJ').should == 'CA - California JJJ'
    end
  end

  context ".abbrev_and_name" do
    it 'should return the correct string' do
      @state.abbrev_and_name.should == 'CA - California'
    end
  end
end

describe State, "class methods" do
  context "#form_selector" do
    @states = State.form_selector
    @states.class.should              == Array
    @states.first.class.should        == Array
    @states.first.first.class.should  == String
    @states.first.last.class.should   == Fixnum
  end

  context 'all_with_country_id(country_id)' do
    before(:each) do
      @country = Country.find(Country::CANADA_ID)
      @states = State.all_with_country_id(@country.id)
    end

    it 'should return an array of States' do
      @states.first.class.should        == State
    end

    it 'should states with country id == country_id' do
      @states.first.country_id.should == @country.id
    end
  end
end
