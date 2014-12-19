require 'spec_helper'

describe ReturnReason do
  describe "Seed data" do
    ReturnReason.all.each do |return_reason|
      it "should be valid" do
        expect(return_reason).to be_valid
      end
    end
  end
end
