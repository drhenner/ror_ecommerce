require 'spec_helper'

describe Batch do
  context " Batch" do
    before(:each) do
      @batch = FactoryGirl.build(:batch)
    end

    it "should be valid with minimum attribues" do
      expect(@batch).to be_valid
    end

  end

end

