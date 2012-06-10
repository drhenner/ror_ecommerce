require 'spec_helper'

describe Coupon do

  context "Percent Coupon" do
    before(:each) do
      @coupon_percent = build(:coupon_percent)
    end

    it "should be valid " do
      @coupon_percent.should be_valid
    end
  end

  context "Value Coupon" do
    before(:each) do
      @coupon_value = build(:coupon_value)
    end

    it "should be valid " do
      @coupon_value.should be_valid
    end
  end

  context "coupon instance methods" do
    before(:each) do
      @order        = create(:order)
      @coupon_value = create(:coupon_value, :amount => 5.00)
    end

    context "value(item_prices)" do
      it "should sum the prices for combine coupons" do
        @coupon_value.stubs(:combine).returns(true)
        @coupon_value.stubs(:qualified?).returns(true)
        @coupon_value.value([2.01, 9.00], @order).should == 5.00
      end

      it "should return the max price for non-combine coupons" do
        @coupon_value.stubs(:combine).returns(false)
        @coupon_value.stubs(:qualified?).returns(true)
        @coupon_value.value([2.01, 9.00], @order).should == 5.00
      end

      it "should return 0.00 for an order that doesnt qualify" do
        @coupon_value.stubs(:combine).returns(true)
        @coupon_value.stubs(:qualified?).returns(false)
        @coupon_value.value([2.01, 9.00], @order).should == 0.00
      end
    end

    context "eligible?(at)" do

      it "should return true" do
        order = create(:order)
        @coupon_value.stubs(:starts_at).returns(Time.now - 1.days)
        @coupon_value.stubs(:expires_at).returns(Time.now + 1.days)
        @coupon_value.eligible?(order).should be_true
      end

      it "should return false" do
        order = create(:order)
        @coupon_value.stubs(:starts_at).returns(Time.now - 3.days)
        @coupon_value.stubs(:expires_at).returns(Time.now - 1.days)
        @coupon_value.eligible?(order).should be_false
      end

      it "should return false" do
        order = create(:order)
        @coupon_value.stubs(:starts_at).returns(Time.now + 1.days)
        @coupon_value.stubs(:expires_at).returns(Time.now + 18.days)
        @coupon_value.eligible?(order).should be_false
      end
    end

    context "qualified?(item_prices, at)" do
      # item_prices.sum > minimum_value

      it "should return true" do
        @coupon_value.stubs(:minimum_value).returns(10.00)
        @coupon_value.stubs(:eligible?).returns(true)
        @coupon_value.qualified?([2.01, 9.00], @order).should be_true
      end

      it "should return false" do
        @coupon_value.stubs(:minimum_value).returns(20.00)
        @coupon_value.qualified?([2.01, 9.00], @order).should be_false
      end
    end

    context ".display_start_time" do
      it "should return the start time formated" do
        if RUBY_VERSION == '1.9.2'
          @coupon_value.starts_at = Time.zone.parse('1/13/2011')
        else # 1.9.3 or greater
          @coupon_value.starts_at = Time.zone.parse('13/1/2011')
        end
        @coupon_value.display_start_time.should == '01/13/2011'
      end

      it "should return N/A" do
        @coupon_value.starts_at = nil
        @coupon_value.display_start_time.should == 'N/A'
      end
    end

    context ".display_expires_time" do
      it "should return the expired time formated" do
        if RUBY_VERSION == '1.9.2'
          @coupon_value.expires_at = Time.zone.parse('1/13/2011')
        else # 1.9.3 or greater
          @coupon_value.expires_at = Time.zone.parse('13/1/2011')
        end
        @coupon_value.display_expires_time.should == '01/13/2011'
      end

      it "should return N/A" do
        @coupon_value.expires_at = nil
        @coupon_value.display_expires_time.should == 'N/A'
      end
    end
  end

  context "coupon instance methods" do
    before(:each) do
      @order        = create(:order)
      @coupon_percent = create(:coupon_percent, :percent => 10)
    end

    context "value(item_prices)" do
      it "should sum the prices for combine coupons" do
        @coupon_percent.stubs(:combine).returns(true)
        @coupon_percent.stubs(:qualified?).returns(true)
        @coupon_percent.value([2.01, 9.00], @order).should == 1.10
      end

      it "should return the max price for non-combine coupons" do
        @coupon_percent.stubs(:combine).returns(false)
        @coupon_percent.stubs(:qualified?).returns(true)
        @coupon_percent.value([2.01, 9.00], @order).should == 0.90
      end

      it "should return 0.00 for an order that doesnt qualify" do
        @coupon_percent.stubs(:combine).returns(true)
        @coupon_percent.stubs(:qualified?).returns(false)
        @coupon_percent.value([2.01, 9.00], @order).should == 0.00
      end
    end
  end

end