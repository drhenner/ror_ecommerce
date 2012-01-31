require 'spec_helper'

describe Country do

  context "#form_selector" do
    @countries = Country.form_selector
    @countries.class.should              == Array
    @countries.first.class.should        == Array
    @countries.first.first.class.should  == String
    @countries.first.last.class.should   == Fixnum
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