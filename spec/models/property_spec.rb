require 'spec_helper'

describe Property do
  context "Valid Property" do
    before(:each) do
      @property = build(:property)
    end

    it "should be valid with minimum attributes" do
      @property.should be_valid
    end
  end

end

describe Property, ".display_active" do
  before(:each) do
    @property = build(:property)
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
  it "should return Properties " do
    property1 = create(:property)
    property2 = create(:property)
    admin_grid = Property.admin_grid
    admin_grid.size.should == 2
    admin_grid.include?(property1).should be_true
    admin_grid.include?(property2).should be_true
  end
end
