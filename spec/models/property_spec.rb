require 'spec_helper'

describe Property do
  context "Valid Property" do
    before(:each) do
      @property = FactoryGirl.build(:property)
    end

    it "should be valid with minimum attributes" do
      expect(@property).to be_valid
    end
  end

end

describe Property, ".display_active" do
  before(:each) do
    @property = FactoryGirl.build(:property)
  end

  it 'should display True if true' do
    @property.active = true
    expect(@property.display_active).to eq 'True'
  end

  it 'should display False if false' do
    @property.active = false
    expect(@property.display_active).to eq 'False'
  end
end

describe Property, "#admin_grid(params = {})" do
  it "should return Properties " do
    property1 = FactoryGirl.create(:property)
    property2 = FactoryGirl.create(:property)
    admin_grid = Property.admin_grid
    expect(admin_grid.size).to eq 2
    expect(admin_grid.include?(property1)).to be true
    expect(admin_grid.include?(property2)).to be true
  end
end
