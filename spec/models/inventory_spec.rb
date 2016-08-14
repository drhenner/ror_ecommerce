# == Schema Information
#
# Table name: inventories
#
#  id                          :integer          not null, primary key
#  count_on_hand               :integer          default(0)
#  count_pending_to_customer   :integer          default(0)
#  count_pending_from_supplier :integer          default(0)
#

require 'spec_helper'

describe Inventory do
  context 'validation working' do
    it 'should not save inventory below out_of_stock limit' do
      inventory = FactoryGirl.build(:inventory,
      :count_on_hand       =>      10,
      :count_pending_to_customer => 11)
      expect(inventory.valid?).to be false
    end

    it 'should not save inventory below out_of_stock limit' do
      inventory = FactoryGirl.build(:inventory,
      :count_on_hand       =>      10,
      :count_pending_to_customer => 11 - Variant::OUT_OF_STOCK_QTY)
      expect(inventory.valid?).to eq true
      expect(inventory.save).to   be true
    end

    it 'should not save inventory below out_of_stock limit' do
      inventory = FactoryGirl.build(:inventory,
      :count_on_hand       =>      100 ,
      :count_pending_to_customer => 101 - Variant::LOW_STOCK_QTY)
      expect(inventory.valid?).to be true
    end
    it 'should not save inventory below out_of_stock limit' do
      inventory = FactoryGirl.build(:inventory,
      :count_on_hand       =>      100 + Variant::LOW_STOCK_QTY,
      :count_pending_to_customer => 0)
      expect(inventory.valid?).to be true
    end

  end

  context ".add_count_on_hand=(num)" do
    it "should send_stock_notifications with qty_to_add" do
      inventory   = FactoryGirl.create(:inventory, :count_on_hand => 100, :count_pending_to_customer => 100)
      @variant    = FactoryGirl.create(:variant,   :inventory => inventory)
      expect(inventory.sold_out?).to be true

      inventory.expects(:send_stock_notifications).with(Variant::OUT_OF_STOCK_QTY + 1).once
      @variant.qty_to_add = Variant::OUT_OF_STOCK_QTY + 1
    end

    it "should send_stock_notifications with qty_to_add" do
      inventory   = FactoryGirl.create(:inventory, :count_on_hand => 100, :count_pending_to_customer => 100)
      @variant    = FactoryGirl.create(:variant,   :inventory => inventory)
      expect(inventory.sold_out?).to be true
      in_stock_message = mock()
      in_stock_message.stubs(:deliver_later)
      InStockNotification.expects(:send!).with(@variant.id).once.returns(in_stock_message)
      @variant.qty_to_add = Variant::OUT_OF_STOCK_QTY + 1
    end

    it "should send OutOfStockNotification with qty_to_add" do
      inventory   = FactoryGirl.create(:inventory, :count_on_hand => Variant::OUT_OF_STOCK_QTY + 1, :count_pending_to_customer => 0)
      @variant    = FactoryGirl.create(:variant,   :inventory => inventory)
      expect(inventory.low_stock?).to be true
      out_of_stock_message = mock()
      out_of_stock_message.stubs(:deliver_later)
      OutOfStockNotification.expects(:send!).with(@variant.id).once.returns(out_of_stock_message)
      @variant.qty_to_add = -1
    end

    it "should send LowStockNotification with qty_to_add" do
      inventory   = FactoryGirl.create(:inventory, :count_on_hand => Variant::LOW_STOCK_QTY + 1, :count_pending_to_customer => 0)
      @variant    = FactoryGirl.create(:variant,   :inventory => inventory)
      expect(inventory.low_stock?).to be false
      low_stock_message = mock()
      low_stock_message.stubs(:deliver_later)
      LowStockNotification.expects(:send!).with(@variant.id).once.returns(low_stock_message)
      @variant.qty_to_add = -1
    end
  end

end
