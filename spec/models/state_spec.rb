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
