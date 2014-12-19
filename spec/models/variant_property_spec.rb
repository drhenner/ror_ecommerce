require 'spec_helper'

describe VariantProperty do
  context "Valid VariantProperty" do
    before(:each) do
      @variant_property = FactoryGirl.build(:variant_property)
    end

    it "should be valid with minimum attributes" do
      expect(@variant_property).to be_valid
    end

    it 'should not be valid' do
      variant   = FactoryGirl.create(:variant)
      property  = FactoryGirl.create(:property)
      FactoryGirl.create(:variant_property, :variant => variant, :property => property)
      variant_property = build(:variant_property, :variant => variant, :property => property)
      expect(variant_property).not_to be_valid
    end
  end

  #
  context " VariantProperty instance methods" do
    it 'should return property_name' do
      property         = FactoryGirl.create(:property, :display_name => 'name')
      variant_property = FactoryGirl.create(:variant_property, :property => property)
      expect(variant_property.property_name).to eq 'name'
    end
  end
end
