require 'spec_helper'

describe Prototype do
  before(:each) do
    @prototype = build(:prototype)
  end

  it "should be valid with minimum attribues" do
    expect(@prototype).to be_valid
  end
end

describe Prototype, "#admin_grid(params = {})" do
  it "should return Prototypes " do
    prototype1 = create(:prototype)
    prototype2 = create(:prototype)
    admin_grid = Prototype.admin_grid
    expect(admin_grid.size).to eq 2
    expect(admin_grid.include?(prototype1)).to be true
    expect(admin_grid.include?(prototype2)).to be true
  end
end
