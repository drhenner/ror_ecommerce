require 'spec_helper'

describe Shipment, 'instance methods' do
  before(:each) do
    User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
    @shipment = FactoryGirl.create(:shipment)
  end

  context '.set_to_shipped' do
    #self.shipped_at = Time.zone.now
    it "should mark the shipment as shipped" do
      @shipment.set_to_shipped
      expect(@shipment.shipped_at).not_to be_nil
    end
  end

  context '.has_items?' do
    # order_items.size > 0
    it 'should not have items' do
      expect(@shipment.has_items?).to be false
    end
    it 'should have items' do
      order_item = FactoryGirl.create(:order_item)
      @shipment.order_items.push(order_item)
      expect(@shipment.has_items?).to be true
    end
  end

  context '.ship_inventory' do
    #order_items.each{ |item| item.variant.subtract_pending_to_customer(1) }
    #order_items.each{ |item| item.variant.subtract_count_on_hand(1) }
    it "should subtract the count on hand and pending to customer for each order_item" do
      @inventory  = FactoryGirl.create(:inventory, :count_on_hand => 100, :count_pending_to_customer => 50)
      @variant    = FactoryGirl.create(:variant, :inventory => @inventory)
      @order_item = FactoryGirl.create(:order_item, :variant => @variant)
      @shipment.order_items.push(@order_item)
      @shipment.ship_inventory
      variant_after_shipment = Variant.find(@variant.id)
      expect(variant_after_shipment.count_on_hand).to eq 99
      expect(variant_after_shipment.count_pending_to_customer).to eq 49
    end
  end

  context '.mark_order_as_shipped' do
    # order.update_attributes(:shipped => true)
    it 'should mark the order shipped' do
      @shipment.order.shipped = false
      @shipment.mark_order_as_shipped
      expect(@shipment.order.shipped).to be true
    end
  end

  context '.display_shipped_at(format = :us_date)' do
    # shipped_at ? shipped_at.strftime(format) : 'Not Shipped.'
    it 'should display the time it was shipped' do
      # I18n.translate('time.formats.us_date')
      now = Time.zone.now
      @shipment.shipped_at = now
      expect(@shipment.display_shipped_at).to eq now.strftime('%m/%d/%Y')
    end

    it 'should diplay "Not Shipped"' do
      @shipment.shipped_at = nil
      expect(@shipment.display_shipped_at).to eq "Not Shipped."
    end
  end

end


describe Shipment, 'instance method from build' do
  before(:each) do
    User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
    @user = FactoryGirl.create(:user)
    @address1 = FactoryGirl.create(:address, :addressable => @user)
    @address2 = FactoryGirl.create(:address, :addressable => @user)
    @order    = FactoryGirl.create(:order, :user => @user)
    @shipment = FactoryGirl.create(:shipment, :order => @order)
  end

  context '.shipping_addresses' do
    # order.user.shipping_addresses
    it 'should return all the shipping addresses for the user' do
      shipment = Shipment.find(@shipment.id)
      expect(shipment.shipping_addresses.map{|a| a.id }.include?(@address1.id)).to be true
      expect(shipment.shipping_addresses.map{|a| a.id }.include?(@address2.id)).to be true
    end
  end
end

describe Shipment, 'instance method from build' do
  before(:each) do
    User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
    @shipment = build(:shipment)
  end

  context '.set_number, save_shipment_number and set_shipment_number' do
    it "should set_number after saving" do
      expect(@shipment.number).to be_nil
      @shipment.save
      expect(@shipment.number).not_to be_nil
      expect(@shipment.number).to eq (Shipment::NUMBER_SEED + @shipment.id).to_s(Shipment::CHARACTERS_SEED)
    end
  end

end

describe Shipment, '#create_shipments_with_items(order)' do
  before(:each) do
    User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
    @order     = FactoryGirl.create(:order)

    #@shipment = build(:shipment, :order => order, :state => 'pending')
  end

  it 'should create shipments with the items in the order'do
    order_item = FactoryGirl.create(:order_item, :order => @order)
    order_item2 = FactoryGirl.create(:order_item, :order => @order)
    @order.order_items.push(order_item)
    @order.order_items.push(order_item2)
    @order.save

    order    = Order.find(@order.id)
    shipment = Shipment.create_shipments_with_items(order)
    order.reload
    expect(order.shipments.size).to eq 2
    #expect(shipment.order_item_ids).to eq order.order_item_ids
  end

  it 'should create 1 shipment with items with the same shipping method'do
    #shipping_method = FactoryGirl.create(:shipping_method)
    shipping_rate = FactoryGirl.create(:shipping_rate)

    order_item  = FactoryGirl.create(:order_item, :order => @order, :shipping_rate => shipping_rate)
    order_item2 = FactoryGirl.create(:order_item, :order => @order, :shipping_rate => shipping_rate)
    @order.order_items.push(order_item)
    @order.order_items.push(order_item2)
    @order.save

    order    = Order.find(@order.id)
    shipment = Shipment.create_shipments_with_items(order)
    order.reload
    expect(order.shipments.size).to eq 1
    #expect(shipment.order_item_ids).to eq order.order_item_ids
  end

end

describe Shipment, 'Class Methods' do
  before(:each) do
    User.any_instance.stubs(:start_store_credits).returns(true)  ## simply speed up tests, no reason to have store_credit object
  end

  describe Shipment, '#find_fulfillment_shipment(id)' do
    it 'should return the shipment' do
      shipment = FactoryGirl.create(:shipment)
      s = Shipment.find_fulfillment_shipment(shipment.id)
      expect(s.id).to eq shipment.id
    end
  end

  describe Shipment, "#id_from_number(num)" do
    it 'should return shipment id' do
      shipment     = FactoryGirl.create(:shipment)
      shipment_id  = Shipment.id_from_number(shipment.number)
      expect(shipment_id).to eq shipment.id
    end
  end

  describe Shipment, "#find_by_number(num)" do
    it 'should find the shipment by number' do
      shipment = FactoryGirl.create(:shipment)
      find_shipment = Shipment.find_by_number(shipment.number)
      expect(find_shipment.id).to eq shipment.id
    end
  end
end
