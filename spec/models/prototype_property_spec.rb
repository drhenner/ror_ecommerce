require 'spec_helper'

#describe PrototypeProperty do
#  it { should validate_presence_of(:property_id) }
#  it { should validate_presence_of(:prototype_id) }
#end

describe PrototypeProperty do
  context "Valid ProductProperty" do
    before(:each) do
      @prototype_property = build(:prototype_property)
    end

    it "should be valid with minimum attributes" do
      @prototype_property.should be_valid
    end

    it "should not be valid without property_id" do
      @prototype_property.property_id = nil
      @prototype_property.should_not be_valid
    end
    it "should not be valid without property_id" do
      @prototype_property.prototype_id = nil
      @prototype_property.should_not be_valid
    end

  end
end
