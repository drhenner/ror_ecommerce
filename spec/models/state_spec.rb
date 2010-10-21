require 'spec_helper'

describe State do
  describe "Valid Seed data" do
    
    State.all do |my_state|
      it "should be valid" do 
        my_state.should be_valid
      end
    end
    
  end
end

describe State, ".abbreviation_name(append_name = )" do
  pending "test for abbreviation_name(append_name = )"
end

describe State, ".abbrev_and_name" do
  pending "test for abbrev_and_name"
end

describe State, "#form_selector" do
  pending "test for form_selector"
end
