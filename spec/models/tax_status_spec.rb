require 'spec_helper'

describe TaxStatus do
  describe "Seed data" do
    TaxStatus.all.each do |tax_status|
      it "should be valid" do 
        tax_status.should be_valid
      end
    end
  end
end