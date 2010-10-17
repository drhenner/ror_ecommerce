require 'spec_helper'

describe Prototype do
  before(:each) do
    @prototype = Factory.build(:prototype)
  end
  
  it "should be valid with minimum attribues" do
    @prototype.should be_valid
  end
end
