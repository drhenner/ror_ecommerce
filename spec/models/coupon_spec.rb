require 'spec_helper'

describe Coupon do

  context "Percent Coupon" do
    before(:each) do
      @coupon_percent = Factory.build(:coupon_percent)
    end

    it "should be valid " do
      @coupon_percent.should be_valid
    end
  end

  context "Value Coupon" do
    before(:each) do
      @coupon_value = Factory.build(:coupon_value)
    end

    it "should be valid " do
      @coupon_value.should be_valid
    end
  end
end
