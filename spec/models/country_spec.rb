require 'spec_helper'

describe Country do
  describe "Valid Seed data" do
    
    Country.all do |country|
      it "should be valid" do 
        country.should be_valid
      end
    end
    
  end
end
