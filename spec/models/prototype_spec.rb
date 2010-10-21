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
  pending "test for display_active"
end

describe Prototype, "#admin_grid(params = {})" do
  pending "test for admin_grid(params = {})"
end
