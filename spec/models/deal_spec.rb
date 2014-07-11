require 'spec_helper'

describe Deal do
  context "Deal.best_qualifing_deal(order)" do
    before(:each) do
      @product_type = create(:product_type)
      @product      = create(:product, :product_type_id => @product_type.id)
      @variant      = create(:variant, :product => @product)
      @variant2      = create(:variant, :product => @product)
      @order        = create(:order)
      @order_item   = create(:order_item, :price => 20.0, :order => @order, :variant => @variant)
      @order_item2   = create(:order_item, :price => 23.0, :order => @order, :variant => @variant2)

      ### Buy 2 get one 50% off

      @deal         = create(:deal, :buy_quantity => 3, :get_percentage => 50, :product_type => @product_type, :created_at => (Time.zone.now - 1.days))

    end

    it 'should return 0.0' do
      @order.stubs(:order_items).returns([@order_item, @order_item2])
      Deal.best_qualifing_deal(@order).should == 0.0
    end

    it 'should return 10.0"' do
      @order_item3   = create(:order_item, :price => 25.0, :order => @order, :variant => @variant2)
      @order.stubs(:order_items).returns([@order_item, @order_item2, @order_item3])
      Deal.best_qualifing_deal(@order).should == 10.0 # $20.00 * 0.50
    end
    it 'should return 11.50"' do
      @order_item3   = create(:order_item, :price => 25.0, :order => @order, :variant => @variant)
      @order_item4   = create(:order_item, :price => 25.0, :order => @order, :variant => @variant2)
      @order.stubs(:order_items).returns([@order_item, @order_item2, @order_item3, @order_item4])
      Deal.best_qualifing_deal(@order).should == 11.5 # $23.00 * 0.50
    end
  end
  context "Deal.best_qualifing_deal(order)" do
    before(:each) do
      @product_type = create(:product_type)
      @product      = create(:product, :product_type_id => @product_type.id)
      @variant      = create(:variant, :product => @product)
      @variant2      = create(:variant, :product => @product)
      @order        = create(:order)
      @order_item   = create(:order_item, :price => 20.0, :order => @order, :variant => @variant)
      @order_item2   = create(:order_item, :price => 23.0, :order => @order, :variant => @variant2)

      ### Buy 2 get one 50% off

      @deal         = create(:deal, buy_quantity: 3, get_percentage: 50, product_type: @product_type, created_at: (Time.zone.now + 1.days))

    end

    it 'should return 0.0 because the deal starts tomorrow' do
      @order_item3   = create(:order_item, :price => 25.0, :order => @order, :variant => @variant2)
      @order.stubs(:order_items).returns([@order_item, @order_item2, @order_item3])
      Deal.best_qualifing_deal(@order).should == 0.0 # $20.00 * 0.50
    end

  end
  context "Deal.best_qualifing_deal(order)" do
    before(:each) do
      @product_type = FactoryGirl.create(:product_type)
      @product      = FactoryGirl.create(:product, :product_type_id => @product_type.id)
      @variant      = FactoryGirl.create(:variant, :product => @product)
      @variant2     = FactoryGirl.create(:variant, :product => @product)
      @order        = FactoryGirl.create(:order, completed_at: nil)
      @order_item   = FactoryGirl.create(:order_item, :price => 20.0, :order => @order, :variant => @variant)
      @order_item2  = FactoryGirl.create(:order_item, :price => 23.0, :order => @order, :variant => @variant2)

      ### Buy 2 get one 50% off

      @deal         = FactoryGirl.create(:deal, :buy_quantity => 3, get_percentage: 50, product_type: @product_type, created_at: (Time.zone.now - 1.days), deleted_at: (Time.zone.now - 2.minutes))

    end

    it 'should return 0.0 because the deal ended 2 minutes ago' do
      @order_item3   = create(:order_item, :price => 25.0, :order => @order, :variant => @variant2)
      @order.stubs(:order_items).returns([@order_item, @order_item2, @order_item3])
      expect(Deal.best_qualifing_deal(@order)).to eq 0.0 # $20.00 * 0.50
    end

  end
  context "Deal.best_qualifing_deal(order)" do
    before(:each) do
      @product_type = create(:product_type)
      @product      = create(:product, :product_type_id => @product_type.id)
      @variant      = create(:variant, :product => @product)
      @variant2      = create(:variant, :product => @product)
      @order        = create(:order)
      @order_item   = create(:order_item, :price => 20.0, :order => @order, :variant => @variant)
      @order_item2   = create(:order_item, :price => 23.0, :order => @order, :variant => @variant2)

      ### Buy 2 get one 50% off

      @deal         = create(:deal, buy_quantity: 3, get_amount: 100, get_percentage: nil, product_type: @product_type, created_at: (Time.zone.now - 1.days))

    end

    it 'should return 0.0 because there are only two items' do
      @order.stubs(:order_items).returns([@order_item, @order_item2])
      Deal.best_qualifing_deal(@order).should == 0.0
    end

    it 'should return 1.00"' do
      @order_item3   = create(:order_item, :price => 25.0, :order => @order, :variant => @variant2)
      @order.stubs(:order_items).returns([@order_item, @order_item2, @order_item3])
      Deal.best_qualifing_deal(@order).should == 1.00 # $20.00 * 0.50
    end

  end

end
