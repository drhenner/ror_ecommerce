require 'spec_helper'

describe Transaction do
  context " Transaction" do
    before(:each) do
      @transaction = build(:transaction)
    end

    it "should be valid with minimum attribues" do
      expect(@transaction).to be_valid
    end

  end

end
