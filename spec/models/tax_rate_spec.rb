require 'spec_helper'

describe TaxRate do
  context "Valid TaxRate" do
    before(:each) do
      @tax_rate = FactoryGirl.build(:tax_rate)
    end

    it "should be valid with minimum attributes" do
      expect(@tax_rate).to be_valid
    end
  end
end
