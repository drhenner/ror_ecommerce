require 'spec_helper'

describe ReturnItem do
  describe "Seed data" do
      before(:each) do
        @return_item = build(:return_item)
      end

      it "should be valid with minimum attributes" do
        @return_item.should be_valid
      end
  end
end