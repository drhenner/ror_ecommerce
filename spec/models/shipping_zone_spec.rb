require 'spec_helper'

describe ShippingZone do
  context "Valid ShippingZone" do
    ShippingZone.all.each do |zone|
      it "should be valid" do
        expect(zone).to be_valid
      end
    end
  end
end
