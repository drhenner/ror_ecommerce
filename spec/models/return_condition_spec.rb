require 'spec_helper'

describe ReturnCondition do
  describe "Seed data" do
    ReturnCondition.all.each do |return_condition|
      it "should be valid" do 
        return_condition.should be_valid
      end
    end
  end
end