require 'spec_helper'

describe Variant, ".sold_out?" do
  pending "test for sold_out?"
end

describe Variant, ".low_stock?" do
  pending "test for low_stock?"
end

describe Variant, ".display_stock_status(start = '(', finish = ')')" do
  pending "test for display_stock_status"
end

describe Variant, ".product_tax_rate(state_id, tax_time = Time.now)" do
  pending "test for product_tax_rate"
end

describe Variant, ".shipping_category_id" do
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

describe Variant, ".display_property_details(separator = '<br/>')" do
  pending "test for display_property_details"
end

describe Variant, ".property_details(separator = ': ')" do
  pending "test for property_details"
end

describe Variant, ".product_name" do
  pending "test for product_name"
end

describe Variant, ".sub_name" do
  pending "test for sub_name"
end

describe Variant, ".primary_property" do
  pending "test for primary_property"
end

describe Variant, ".name_with_sku" do
  pending "test for name_with_sku"
end

describe Variant, ".qty_to_add" do
  pending "test for qty_to_add"
end

describe Variant, ".is_available?" do
  pending "test for is_available?"
end

describe Variant, ".count_available(reload_variant = true)" do
  pending "test for count_available"
end

describe Variant, ".add_count_on_hand(num)" do
  pending "test for add_count_on_hand"
end

describe Variant, ".subtract_count_on_hand(num)" do
  pending "test for subtract_count_on_hand(num)"
end

describe Variant, ".add_pending_to_customer(num)" do
  pending "test for add_pending_to_customer(num)"
end

describe Variant, ".subtract_pending_to_customer(num)" do
  pending "test for subtract_pending_to_customer(num)"
end

describe Variant, ".qty_to_add=(num)" do
  pending "test for qty_to_add=(num)"
end

describe Variant, "#admin_grid(product, params = {})" do
  pending "test for admin_grid"
end
