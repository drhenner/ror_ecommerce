require 'spec_helper'

describe Account do
  context "Valid Account" do
    before(:each) do
      @account = FactoryBot.build(:account)
    end

    it "should be valid with minimum attributes" do
      expect(@account).to be_valid
    end

  end

end
