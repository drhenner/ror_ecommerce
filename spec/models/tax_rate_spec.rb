require 'spec_helper'

describe TaxRate do
  context "Valid TaxRate" do
    before(:each) do
      @tax_rate = build(:tax_rate)
    end

    it "should be valid with minimum attributes" do
      @tax_rate.should be_valid
    end

    describe "#country" do
      before do
        @country = mock
        @tax_rate.state.stubs(:country).returns(@country)
      end
      it "should return the country of associated state" do
        @tax_rate.country.should == @country
      end

      it "should respond to country= and do nothing" do
        other_country = mock
        @tax_rate.country = other_country
        @tax_rate.country.should == @country
      end
    end
  end
end
