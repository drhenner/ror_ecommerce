require 'spec_helper'

describe ShippingRateType do
  context "Valid ShippingRateType" do
    ShippingRateType.all.each do |rate|
      it "should be valid" do
        expect(rate).to be_valid
      end
    end
  end#end of context
end
