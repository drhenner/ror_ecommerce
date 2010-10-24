require 'spec_helper'

describe Property do
  context "Valid Property" do
    before(:each) do
      @property = Factory.build(:property)
    end
    
    it "should be valid with minimum attributes" do
      @property.should be_valid
    end
  end
  
end

describe Property, ".display_active" do
  before(:each) do
    @property = Factory.build(:property)
  end
  
  it 'should display True if true' do
    @property.active = true
    @property.display_active.should == 'True'
  end
  
  it 'should display False if false' do
    @property.active = false
    @property.display_active.should == 'False'
  end
end

describe Property, "#admin_grid(params = {})" do
  pending "test for admin_grid(params = {})"
end
