require 'spec_helper'

describe VariantSupplier do
  context "Valid VariantSupplier" do
    before(:each) do
      @variant_supplier = build(:variant_supplier)
    end
    
    it "should be valid with minimum attributes" do
      @variant_supplier.should be_valid
    end
    
  end
  
end
