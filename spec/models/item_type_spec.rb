require 'spec_helper'

describe ItemType do
  describe "Seed data" do
    ItemType.all.each do |item_type|
      it "should be valid" do
        expect(item_type).to be_valid
      end
    end
  end
end
