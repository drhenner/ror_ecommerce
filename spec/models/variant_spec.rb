require 'spec_helper'

describe Variant, " instance methods" do
  before(:each) do
    @variant = Factory(:variant)
  end
  # OUT_OF_STOCK_QTY = 2
  # LOW_STOCK_QTY    = 6
  context ".sold_out?" do
    it 'should be sold out' do
      @variant.count_on_hand             = 100
      @variant.count_pending_to_customer = 100 - Variant::OUT_OF_STOCK_QTY
      @variant.sold_out?.should be_true
      
    end
  
    it 'should not be sold out' do
      @variant.count_on_hand             = 100
      @variant.count_pending_to_customer = 99 - Variant::OUT_OF_STOCK_QTY
      @variant.sold_out?.should be_false
    end
  
  end

  context ".low_stock?" do
    pending "test for low_stock?"
  end

  context ".display_stock_status(start = '(', finish = ')')" do
    pending "test for display_stock_status"
  end

  context ".product_tax_rate(state_id, tax_time = Time.now)" do
    pending "test for product_tax_rate"
  end

  context ".shipping_category_id" do
    pending "test for shipping_category_id"
  end

  #
  #def total_price(tax_rate)
  #  ((1 + tax_percentage(tax_rate)) * self.price)
  #end
  #
  #def tax_percentage(tax_rate)
  #  tax_rate ? tax_rate.percentage : 0
  #end

  context ".display_property_details(separator = '<br/>')" do
    pending "test for display_property_details"
  end

  context ".property_details(separator = ': ')" do
    pending "test for property_details"
  end

  context ".product_name" do
    pending "test for product_name"
  end

  context ".sub_name" do
    pending "test for sub_name"
  end

  context ".primary_property" do
    pending "test for primary_property"
  end

  context ".name_with_sku" do
    pending "test for name_with_sku"
  end

  context ".qty_to_add" do
    pending "test for qty_to_add"
  end

  context ".is_available?" do
    pending "test for is_available?"
  end

  context ".count_available(reload_variant = true)" do
    pending "test for count_available"
  end

  context ".add_count_on_hand(num)" do
    pending "test for add_count_on_hand"
  end

  context ".subtract_count_on_hand(num)" do
    pending "test for subtract_count_on_hand(num)"
  end

  context ".add_pending_to_customer(num)" do
    pending "test for add_pending_to_customer(num)"
  end

  context ".subtract_pending_to_customer(num)" do
    pending "test for subtract_pending_to_customer(num)"
  end

  context ".qty_to_add=(num)" do
    pending "test for qty_to_add=(num)"
  end
end

describe Variant, "#admin_grid(product, params = {})" do
  pending "test for admin_grid"
end
