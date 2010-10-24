require 'spec_helper'

describe PurchaseOrder do
  before(:each) do
    @purchase_order = Factory.build(:purchase_order)
  end
  
  it "should be valid with minimum attribues" do
    @purchase_order.should be_valid
  end
end

describe PurchaseOrder, ".display_received" do
  it "should return Yes when true" do
    order = Factory.build(:purchase_order)
    order.stubs(:is_received).returns(true)

    order.display_received == "Yes"
  end
end

describe PurchaseOrder, ".display_received" do
  it "should return No when false" do
    order = Factory.build(:purchase_order)
    order.stubs(:is_received).returns(false)

    order.display_received == "No"
  end
end

describe PurchaseOrder, ".display_estimated_arrival_on" do
  it "should return the correct name" do
    order = Factory.build(:purchase_order)
    now = Time.now
    order.stubs(:estimated_arrival_on).returns(now.to_date)

    order.display_estimated_arrival_on == now.to_s(:us_date)
  end
end

describe PurchaseOrder, ".supplier_name" do
  it "should return the correct name" do
    order = Factory.build(:purchase_order)
    supplier = Factory.build(:supplier)
    supplier.stubs(:name).returns("Supplier Test")
    order.stubs(:supplier).returns(supplier)

    order.supplier_name == "Supplier Test"
  end
end

describe PurchaseOrder, ".receive_po=(answer)" do
  pending "test for receive_po=(answer)"
end

describe PurchaseOrder, ".receive_po" do
  pending "test for receive_po"
end

describe PurchaseOrder, ".receive_variants" do
  pending "test for receive_variants"
end

describe PurchaseOrder, ".display_tracking_number" do
  pending "test for display_tracking_number"
end

describe PurchaseOrder, "#admin_grid(params = {})" do
  pending "test for admin_grid(params = {})"
end

describe PurchaseOrder, "#receiving_admin_grid(params = {})" do
  pending "test for receiving_admin_grid(params = {})"
end
