require 'spec_helper'

describe TaxRate do
  context "Valid TaxRate" do
    before(:each) do
      @tax_rate = build(:tax_rate)
    end
  
    it "should be valid with minimum attributes" do
      @tax_rate.should be_valid
    end
  end
end
