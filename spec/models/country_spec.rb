require 'spec_helper'

describe Country do

  context "#form_selector" do
    it 'should return the correct objects' do
      @countries = Country.form_selector
      expect(@countries.class.to_s).to              eq 'Array'
      expect(@countries.first.class.to_s).to        eq 'Array'
      expect(@countries.first.first.class.to_s).to  eq 'String'
      expect(@countries.first.last.class.to_s).to   eq 'Integer'
    end
  end
end

describe Country do
  before(:each) do
    @country ||= Country.new( :abbreviation => 'US', :name => 'United States')
  end

  context ".abbreviation_name(append_name = )" do

    it 'should return the correct string with no params' do
      expect(@country.abbreviation_name).to eq 'US - United States'
    end

    it 'should return the correct string with  params' do
      expect(@country.abbreviation_name('JJJ')).to eq 'US - United States JJJ'
    end
  end

  context ".abbrev_and_name" do
    it 'should return the correct string' do
      expect(@country.abbrev_and_name).to eq 'US - United States'
    end
  end
end
