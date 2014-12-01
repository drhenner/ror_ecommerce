require 'spec_helper'

describe Brand do
  context " Brand" do
    before(:each) do
      @brand = FactoryGirl.build(:brand)
    end

    it "should be valid with minimum attribues" do
      expect(@brand).to be_valid
    end

  end

end
