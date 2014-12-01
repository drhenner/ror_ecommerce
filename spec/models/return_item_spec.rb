require 'spec_helper'

describe ReturnItem do
  describe "Seed data" do
      before(:each) do
        @return_item = FactoryGirl.build(:return_item)
      end

      it "should be valid with minimum attributes" do
        expect(@return_item).to be_valid
      end
  end
end
