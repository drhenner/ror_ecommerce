require 'spec_helper'

describe Country do
  describe "Valid Seed data" do
    
    Country.all.each do |country|
      it "should be valid" do 
        country.should be_valid
      end
    end
    
  end
end
