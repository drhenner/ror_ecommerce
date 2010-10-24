require 'spec_helper'

describe Prototype do
  before(:each) do
    @prototype = Factory.build(:prototype)
  end
  
  it "should be valid with minimum attribues" do
    @prototype.should be_valid
  end
end

describe Prototype, ".display_active" do
  before(:each) do
    @prototype = Factory.build(:prototype)
  end
  
  it 'should display True if true' do
    @prototype.active = true
    @prototype.display_active.should == 'True'
    
    @prototype.active = false
    @prototype.display_active.should == 'False'
  end
end

describe Prototype, "#admin_grid(params = {})" do
  pending "test for admin_grid(params = {})"
end
