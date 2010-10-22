require 'spec_helper'

describe State do
  describe "Valid Seed data" do
    
    State.all.each do |my_state|
      it "should be valid" do 
        my_state.should be_valid
      end
    end
    
  end
end


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

  context "#form_selector" do
    @states = State.form_selector
    @states.class.should              == Array
    @states.first.class.should        == Array
    @states.first.first.class.should  == String
    @states.first.last.class.should   == Fixnum
  end
end
