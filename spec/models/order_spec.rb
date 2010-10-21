require 'spec_helper'

describe Order do
  pending "add some examples to (or delete) #{__FILE__}"
end

describe Order, ".name" do
  pending "test for name"
end

describe Order, ".display_completed_at(format = :us_date)" do
  pending "test for display_completed_at(format = :us_date)"
end

describe Order, ".first_invoice_amount" do
  pending "test for first_invoice_amount"
end

describe Order, ".cancel_unshipped_order(invoice)" do
  pending "test for cancel_unshipped_order(invoice)"
end

describe Order, ".status" do
  pending "test for status"
end

describe Order, "#find_myaccount_details" do
  pending "test for find_myaccount_details"
end

describe Order, "#new_admin_cart(admin_cart, args = {})" do
  pending "test for new_admin_cart(admin_cart, args = {})"
end

describe Order, ".capture_invoice(invoice)" do
  pending "test for capture_invoice(invoice)"
end

describe Order, ".create_invoice(credit_card, charge_amount, args)" do
  pending "test for create_invoice(credit_card, charge_amount, args)"
end

describe Order, ".create_invoice_transaction(credit_card, charge_amount, args)" do
  pending "test for create_invoice_transaction(credit_card, charge_amount, args)"
end

describe Order, ".order_complete!" do
  pending "test for order_complete!"
end

describe Order, ".set_beginning_values" do
  pending "test for set_beginning_values"
end

describe Order, ".update_tax_rates" do
  pending "test for update_tax_rates"
end

describe Order, ".calculate_totals(force = false)" do
  pending "test for calculate_totals(force = false)"
end

describe Order, ".order_total(force = false)" do
  pending "test for order_total(force = false)"
end

describe Order, ".ready_to_checkout?" do
  pending "test for ready_to_checkout?"
end

describe Order, ".find_total(force = false)" do
  pending "test for find_total(force = false)"
end

describe Order, ".shipping_charges" do
  pending "test for shipping_charges"
end

describe Order, ".update_address(address_type_id , address_id)" do
  pending "test for update_address(address_type_id , address_id)"
end

describe Order, ".add_items(variant, quantity, state_id = nil)" do
  pending "test for add_items(variant, quantity, state_id = nil)"
end

describe Order, ".new_items(variant, quantity, state_id = nil)" do
  pending "test for new_items(variant, quantity, state_id = nil)"
end

describe Order, ".set_email" do
  pending "test for set_email"
end

describe Order, ".set_number" do
  pending "test for set_number"
end

describe Order, ".set_order_number" do
  pending "test for set_order_number"
end

describe Order, ".save_order_number" do
  pending "test for save_order_number"
end

describe Order, "#id_from_number(num)" do
  pending "test for id_from_number(num)"
end

describe Order, "#find_by_number(num)" do
  pending "test for find_by_number(num)"
end

describe Order, ".update_inventory" do
  pending "test for update_inventory"
end

describe Order, ".variant_ids" do
  pending "test for variant_ids"
end

describe Order, ".has_shipment?" do
  pending "test for has_shipment?"
end

describe Order, "#find_finished_order_grid(params = {})" do
  pending "test for find_finished_order_grid(params = {})"
end

describe Order, "#fulfillment_grid(params = {})" do
  pending "test for fulfillment_grid(params = {})"
end
