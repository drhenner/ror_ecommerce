require 'spec_helper'

describe VariantSupplier do
  context "Valid VariantSupplier" do
    before(:each) do
      @variant_supplier = FactoryGirl.build(:variant_supplier)
    end

    it "should be valid with minimum attributes" do
      expect(@variant_supplier).to be_valid
    end

  end

end
