require 'spec_helper'

#describe PrototypeProperty do
#  it { should validate_presence_of(:property_id) }
#  it { should validate_presence_of(:prototype_id) }
#end

describe PrototypeProperty do
  context "Valid ProductProperty" do
    before(:each) do
      @prototype_property = FactoryGirl.build(:prototype_property)
    end

    it "should be valid with minimum attributes" do
      expect(@prototype_property).to be_valid
    end

    it "should not be valid without property_id" do
      @prototype_property.property_id = nil
      expect(@prototype_property).not_to be_valid
    end

  end
end
