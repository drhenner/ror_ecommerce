require 'spec_helper'

describe Country do
  context "#form_selector" do
    it "should return only the active countries" do
      @countries = Country.form_selector
      @countries.collect(&:id).should == Country::ACTIVE_COUNTRY_IDS
      @countries.collect(&:name).should == ["Canada", "United States"]
    end
  end
end

describe Country do
  before(:each) do
    @country ||= Country.new( :abbreviation => 'US', :name => 'United States')
  end

  context ".abbreviation_name(append_name = )" do
    it 'should return the correct string with no params' do
      @country.abbreviation_name.should == 'US - United States'
    end

    it 'should return the correct string with  params' do
      @country.abbreviation_name('JJJ').should == 'US - United States JJJ'
    end
  end

  context ".abbrev_and_name" do
    it 'should return the correct string' do
      @country.abbrev_and_name.should == 'US - United States'
    end
  end
end
