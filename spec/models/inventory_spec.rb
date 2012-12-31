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
      inventory.valid?.should == false
    end

    it 'should not save inventory below out_of_stock limit' do
      inventory = FactoryGirl.build(:inventory,
      :count_on_hand       =>      10,
      :count_pending_to_customer => 11 - Variant::OUT_OF_STOCK_QTY)
      inventory.valid?.should == true
      inventory.save.should be_true
    end

    it 'should not save inventory below out_of_stock limit' do
      inventory = FactoryGirl.build(:inventory,
      :count_on_hand       =>      100 ,
      :count_pending_to_customer => 101 - Variant::LOW_STOCK_QTY)
      inventory.valid?.should == true
    end
    it 'should not save inventory below out_of_stock limit' do
      inventory = FactoryGirl.build(:inventory,
      :count_on_hand       =>      100 + Variant::LOW_STOCK_QTY,
      :count_pending_to_customer => 0)
      inventory.valid?.should == true
    end

  end

end
