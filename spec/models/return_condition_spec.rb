require 'spec_helper'

describe ReturnCondition do
  describe "Seed data" do
    ReturnCondition.all.each do |return_condition|
      it "should be valid" do
        expect(return_condition).to be_valid
      end
    end
  end
end
