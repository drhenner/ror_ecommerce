require 'spec_helper'


describe OrderItem, "instance methods" do

  before(:each) do
    #@order = create(:order)
    @order_item = create(:order_item)#, :order => @order)
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
      shipping_rate = create(:shipping_rate)
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
    it 'should be ready to calculate if we know the shipping rate and tax rate' do
      @order_item.shipping_rate_id = 1
      @order_item.tax_rate_id = 1
      @order_item.ready_to_calculate?.should be_true
    end

    it 'should not be ready to calculate if we dont know the shipping rate ' do
      @order_item.shipping_rate_id = nil
      @order_item.tax_rate_id = 1
      @order_item.ready_to_calculate?.should be_false
    end

    it 'should not be ready to calculate if we know the tax rate' do
      @order_item.shipping_rate_id = 1
      @order_item.tax_rate_id = nil
      @order_item.ready_to_calculate?.should be_false
    end
  end
end
describe OrderItem, "Without VAT" do

  before(:all) do
    Settings.vat = false
  end
  context ".calculate_total(coupon = nil)" do
    it 'should calculate_total' do
      tax_rate = create(:tax_rate, :percentage => 10.0)
      order_item = create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      order_item.calculate_total
      order_item.total.should == 22.00
    end
  end

  context ".tax_charge" do
    it 'should return tax_charge' do
      tax_rate = create(:tax_rate, :percentage => 10.0)
      order_item = create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      order_item.tax_charge.should == 2.00
    end
  end

  context ".amount_of_charge_is_vat" do
    it 'should return tax_charge' do
      tax_rate = create(:tax_rate, :percentage => 10.0)
      order_item = create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      order_item.amount_of_charge_is_vat.should == 0.00
    end
  end

  context ".amount_of_charge_without_vat" do
    it 'should return tax_charge' do
      tax_rate = create(:tax_rate, :percentage => 10.0)
      order_item = create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      order_item.amount_of_charge_without_vat.should == 20.00
    end
  end
end
describe OrderItem, "With VAT" do
  before(:all) do
    Settings.vat = true
  end
  context ".calculate_total(coupon = nil)" do
    it 'should calculate_total' do
      tax_rate = create(:tax_rate, :percentage => 10.0)
      order_item = create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      order_item.calculate_total
      order_item.total.should == 20.00
    end
  end

  context ".tax_charge" do
    it 'should return tax_charge' do
      tax_rate = create(:tax_rate, :percentage => 10.0)
      order_item = create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      order_item.tax_charge.should == 0.00
    end
  end

  context ".amount_of_charge_is_vat" do
    it 'should return tax_charge' do
      tax_rate = create(:tax_rate, :percentage => 10.0)
      order_item = create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      order_item.amount_of_charge_is_vat.should == 1.82
    end
  end

  context ".amount_of_charge_without_vat" do
    it 'should return tax_charge' do
      tax_rate = create(:tax_rate, :percentage => 10.0)
      order_item = create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      order_item.amount_of_charge_without_vat.should == 18.18
    end
  end
end
describe OrderItem, "#order_items_in_cart(order_id)" do
  pending "test for order_items_in_cart(order_id)"
end
