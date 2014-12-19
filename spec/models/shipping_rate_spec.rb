require 'spec_helper'

describe ShippingRate, 'instance methods' do
  before(:each) do
    @shipping_rate = build(:shipping_rate, :rate => 5.50)
  end

  context ".individual?" do
    # shipping_rate_type_id == ShippingRateType::INDIVIDUAL_ID
    it "should return true" do
      ship_rate_type = ShippingRateType.find_by_name('Individual')
      @shipping_rate.shipping_rate_type = ship_rate_type
      expect(@shipping_rate.individual?).to be true
    end

    it "should return true" do
      ship_rate_type = ShippingRateType.find_by_name('Order')
      @shipping_rate.shipping_rate_type = ship_rate_type
      expect(@shipping_rate.individual?).to be false
    end
  end

  context ".name" do
    #[shipping_method.name, shipping_method.shipping_zone.name, sub_name].join(', ')
    it "should return the name" do
      ship_rate_type = ShippingRateType.find_by_name('Individual')
      @shipping_rate.shipping_rate_type = ship_rate_type
      shipping_method = FactoryGirl.create(:shipping_method, :name => 'shipname')
      @shipping_rate.shipping_method = shipping_method
      expect(@shipping_rate.name).to eq 'shipname, USA, (Individual - 5.5)'
    end
  end

  context ".sub_name" do
    # '(' + [shipping_rate_type.name, rate ].join(' - ') + ')'
    it "should return the sub_name" do
      ship_rate_type = ShippingRateType.find_by_name('Individual')
      @shipping_rate.shipping_rate_type = ship_rate_type
      expect(@shipping_rate.sub_name).to eq '(Individual - 5.5)'
    end
  end

  context ".name_with_rate" do
    # [shipping_method.name, number_to_currency(rate)].join(' - ')
    it "should return the name_with_rate" do
      shipping_method = FactoryGirl.create(:shipping_method, :name => 'shipname')
      @shipping_rate.shipping_method = shipping_method
      @shipping_rate.stubs(:individual?).returns(false)
      expect(@shipping_rate.name_with_rate).to eq 'shipname - $5.50'
    end
    it "should return the name_with_rate" do
      shipping_method = FactoryGirl.create(:shipping_method, :name => 'shipname')
      @shipping_rate.shipping_method = shipping_method
      @shipping_rate.stubs(:individual?).returns(true)
      expect(@shipping_rate.name_with_rate).to eq 'shipname - $5.50 / item'
    end
  end
end
