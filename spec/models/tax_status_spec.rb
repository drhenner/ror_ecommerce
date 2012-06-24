require 'spec_helper'

describe TaxCategory do
  describe "Seed data" do
    TaxCategory.all.each do |tax_cat|
      it "should be valid" do 
        tax_cat.should be_valid
      end
    end
  end
end