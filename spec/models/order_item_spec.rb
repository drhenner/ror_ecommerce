require 'spec_helper'


describe OrderItem, "instance methods" do

  before(:each) do
    #@order = FactoryGirl.create(:order)
    @order_item = FactoryGirl.create(:order_item)#, :order => @order)
  end

  context ".shipped?" do
    it 'should return true if there is a shipment_id' do
      @order_item.shipment_id = 1
      expect(@order_item.shipped?).to be true
    end

    it 'should return false if there is a shipment_id' do
      @order_item.shipment_id = nil
      expect(@order_item.shipped?).to be false
    end
  end

  context ".sale_price(at)" do
    it 'should return the price - % discount ' do
      product = FactoryGirl.create(:product)
      variant = FactoryGirl.create(:variant, :product => product)
      new_sale = FactoryGirl.create(:sale,
                                    :product_id   => product.id,
                                    :starts_at    => (Time.zone.now - 1.days),
                                    :ends_at      => (Time.zone.now + 1.days),
                                    :percent_off  => 0.20
                                    )

      sale = Sale.for(product.id, Time.zone.now)
      expect(sale.id).to eq new_sale.id

      @order_item.stubs(:price).returns(100.0)
      @order_item.stubs(:variant).returns(variant)
      expect(@order_item.sale_price(Time.zone.now)).to eq 80.0
    end
  end

  context ".shipping_method" do
    #shipping_rate.shipping_method
    it 'should return the shipping method' do
      expect(@order_item.shipping_method).to eq @order_item.shipping_rate.shipping_method
    end
  end

  context ".shipping_method_id" do
    it 'should return the shipping method id' do
      expect(@order_item.shipping_method_id).to eq @order_item.shipping_rate.shipping_method_id
    end
  end

  context ".calculate_order" do
    it 'should calculate order once after calling method twice' do
      order     = mock()
      @order_item.stubs(:ready_to_calculate?).returns(true)
      @order_item.stubs(:order).returns(order)
      shipping_rate = FactoryGirl.create(:shipping_rate)
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
      expect(@order_item.order.calculated_at).to be nil
    end
  end

  context ".ready_to_calculate?" do
    it 'should be ready to calculate if we know the shipping rate and tax rate' do
      @order_item.shipping_rate_id = 1
      @order_item.tax_rate_id = 1
      expect(@order_item.ready_to_calculate?).to be_truthy
    end

    it 'should not be ready to calculate if we dont know the shipping rate ' do
      @order_item.shipping_rate_id = nil
      @order_item.tax_rate_id = 1
      expect(@order_item.ready_to_calculate?).to be_falsey
    end

    it 'should not be ready to calculate if we know the tax rate' do
      @order_item.shipping_rate_id = 1
      @order_item.tax_rate_id = nil
      expect(@order_item.ready_to_calculate?).to be_falsey
    end
  end
end
describe OrderItem, "Without VAT" do

  before(:all) do
    Settings.vat = false
  end
  context ".calculate_total(coupon = nil)" do
    it 'should calculate_total' do
      tax_rate = FactoryGirl.create(:tax_rate, :percentage => 10.0)
      order_item = FactoryGirl.create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      order_item.calculate_total
      expect(order_item.total).to eq 20.00
    end
  end

  context ".tax_charge" do
    it 'should return tax_charge' do
      tax_rate = FactoryGirl.create(:tax_rate, :percentage => 10.0)
      order_item = FactoryGirl.create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      expect(order_item.tax_charge).to eq 2.00
    end
  end

  context ".amount_of_charge_is_vat" do
    it 'should return tax_charge' do
      tax_rate = FactoryGirl.create(:tax_rate, :percentage => 10.0)
      order_item = FactoryGirl.create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      expect(order_item.amount_of_charge_is_vat).to eq 0.00
    end
  end

  context ".amount_of_charge_without_vat" do
    it 'should return tax_charge' do
      tax_rate = FactoryGirl.create(:tax_rate, :percentage => 10.0)
      order_item = FactoryGirl.create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      expect(order_item.amount_of_charge_without_vat).to eq 20.00
    end
  end
end
describe OrderItem, "With VAT" do
  before(:all) do
    Settings.vat = true
  end
  context ".calculate_total(coupon = nil)" do
    it 'should calculate_total' do
      tax_rate = FactoryGirl.create(:tax_rate, :percentage => 10.0)
      order_item = FactoryGirl.create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      order_item.calculate_total
      expect(order_item.total).to eq 20.00
    end
  end

  context ".tax_charge" do
    it 'should return tax_charge' do
      tax_rate = FactoryGirl.create(:tax_rate, :percentage => 10.0)
      order_item = FactoryGirl.create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      expect(order_item.tax_charge).to eq 0.00
    end
  end

  context ".amount_of_charge_is_vat" do
    it 'should return tax_charge' do
      tax_rate = FactoryGirl.create(:tax_rate, :percentage => 10.0)
      order_item = FactoryGirl.create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      expect(order_item.amount_of_charge_is_vat).to eq 1.82
    end
  end

  context ".amount_of_charge_without_vat" do
    it 'should return tax_charge' do
      tax_rate = FactoryGirl.create(:tax_rate, :percentage => 10.0)
      order_item = FactoryGirl.create(:order_item, :tax_rate => tax_rate, :price => 20.00)
      expect(order_item.amount_of_charge_without_vat).to eq 18.18
    end
  end
end
describe OrderItem, "#order_items_in_cart(order_id)" do
  skip "test for order_items_in_cart(order_id)"
end
