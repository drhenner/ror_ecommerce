require 'spec_helper'

describe Shipment, 'instance methods' do
  before(:each) do
    @shipment = Factory(:shipment)
  end
  
  context '.set_to_shipped' do
    #self.shipped_at = Time.zone.now
    it "should mark the shipment as shipped" do
      @shipment.set_to_shipped
      @shipment.shipped_at.should_not be_nil
    end
  end

  context '.has_items?' do
    # order_items.size > 0
    it 'should not have items' do
      @shipment.has_items?.should be_false
    end
    it 'should have items' do
      order_item = Factory(:order_item)
      @shipment.order_items.push(order_item)
      @shipment.has_items?.should be_false
    end
  end

  context '.ship_inventory' do
    #order_items.each{ |item| item.variant.subtract_pending_to_customer(1) }
    #order_items.each{ |item| item.variant.subtract_count_on_hand(1) }
    it "should subtract the count on hand and pending to customer for each order_item" do
      variant    = Factory(:variant, :count_on_hand => 100, :count_pending_to_customer => 50)
      order_item = Factory(:order_item, :variant => variant)
      @shipment.order_items.push(order_item)
      @shipment.ship_inventory
      variant_after_shipment = Variant.find(variant.id)
      variant_after_shipment.count_on_hand.should == 99
      variant_after_shipment.count_pending_to_customer.should == 49
    end
  end

  context '.mark_order_as_shipped' do
    pending "test for mark_order_as_shipped"
  end

  context '.display_shipped_at(format = :us_date)' do
    pending "test for display_shipped_at(format = :us_date)"
  end

  context '.set_number' do
    pending "test for set_number"
  end

  context '.set_shipment_number' do
    pending "test for set_shipment_number"
  end

  context '.save_shipment_number' do
    pending "test for save_shipment_number"
  end

  context '.shipping_addresses' do
    pending "test for shipping_addresses"
  end

end

describe Shipment, '#create_shipments_with_items(order)' do
  pending "test for create_shipments_with_items(order)"
end

describe Shipment, '#find_fulfillment_shipment(id)' do
  pending "test for find_fulfillment_shipment(id)"
end

describe Shipment, '#id_from_number(num)' do
  pending "test for id_from_number(num)"
end

describe Shipment, '#find_by_number(num)' do
  pending "test for find_by_number(num)"
end