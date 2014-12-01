require 'spec_helper'

describe PurchaseOrderVariant, "instance methods" do
  before(:each) do
    @inventory              = FactoryGirl.create(:inventory, :count_on_hand => 100, :count_pending_to_customer => 50)
    @variant                = FactoryGirl.create(:variant, :inventory => @inventory)
    @purchase_order_variant = FactoryGirl.create(:purchase_order_variant, :variant => @variant, :quantity => 10)
  end

  context ".receive!" do
    it 'should call receive if true' do
      @purchase_order_variant.receive!
      expect(@purchase_order_variant.variant.inventory.count_on_hand).to eq 110
    end

    it 'should mark purchase order complete' do
      @purchase_order_variant.purchase_order.expects(:mark_as_complete).once
      @purchase_order_variant.receive!
    end
  end

  context ".receive_po=(answer)" do
    it 'should call receive if true' do
      @purchase_order_variant.expects(:receive!).once
      @purchase_order_variant.receive_po=('true')
    end
    it 'should call receive if 1' do
      @purchase_order_variant.expects(:receive!).once
      @purchase_order_variant.receive_po=('1')
    end
    it 'should call receive if 0' do
      @purchase_order_variant.expects(:receive!).never
      @purchase_order_variant.receive_po=('0')
    end
  end

  context ".receive_po" do
    #is_received
    it 'should be true' do
      @purchase_order_variant.is_received = true
      expect(@purchase_order_variant.receive_po).to be true
    end

    it 'should call receive if 0' do
      @purchase_order_variant.is_received = false
      expect(@purchase_order_variant.receive_po).to be false
    end
  end
end
