require 'spec_helper'


describe OrderItem, "instance methods" do
  
  before(:each) do 
    #@order = Factory(:order)
    @order_item = Factory(:order_item)#, :order => @order)
  end
  
  context ".shipped?" do
    it 'should return true if there is a shipment_id' do
      @order_item.shipment_id = 1
      @order_item.shipped?.should be_true
    end
    
    it 'should return false if there is a shipment_id' do
      @order_item.shipment_id = nil
      @order_item.shipped?.should be_false
    end
  end

  context ".shipping_method" do
    #shipping_rate.shipping_method
    it 'should return the shipping method' do
      @order_item.shipping_method.should == @order_item.shipping_rate.shipping_method
    end
  end

  context ".shipping_method_id" do
    it 'should return the shipping method id' do
      @order_item.shipping_method_id.should == @order_item.shipping_rate.shipping_method_id
    end
  end

  context ".calculate_order" do
    it 'should calculate order once after calling method twice' do
      order     = mock()
      @order_item.stubs(:ready_to_calculate?).returns(true)
      @order_item.stubs(:order).returns(order)
      shipping_rate = Factory(:shipping_rate)
      @order_item.shipping_rate = shipping_rate
      @order_item.order.expects(:calculate_totals).once
      @order_item.calculate_order
      @order_item.calculate_order
    end
  end

  context ".set_order_calculated_at_to_nil" do
    it 'should return the shipping method id' do
      @order_item.order.calculated_at = Time.now
      @order_item.set_order_calculated_at_to_nil
      @order_item.order.calculated_at.should == nil
    end
  end

  context ".ready_to_calculate?" do
    pending "test for ready_to_calculate?"
  end

  context ".calculate_total(coupon = nil)" do
    pending "test for calculate_total(coupon = nil)"
  end
end

describe OrderItem, "#order_items_in_cart(order_id)" do
  pending "test for order_items_in_cart(order_id)"
end