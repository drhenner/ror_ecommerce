require 'spec_helper'

describe Prototype do
  before(:each) do
    @prototype = build(:prototype)
  end
  
  it "should be valid with minimum attribues" do
    @prototype.should be_valid
  end
end

describe Prototype, ".display_active" do
  before(:each) do
    @prototype = build(:prototype)
  end
  
  it 'should display True if true' do
    @prototype.active = true
    @prototype.display_active.should == 'True'
    
    @prototype.active = false
    @prototype.display_active.should == 'False'
  end
end

describe Prototype, "#admin_grid(params = {})" do
  it "should return Prototypes " do
    prototype1 = create(:prototype)
    prototype2 = create(:prototype)
    admin_grid = Prototype.admin_grid
    admin_grid.size.should == 2
    admin_grid.include?(prototype1).should be_true
    admin_grid.include?(prototype2).should be_true
  end
end
