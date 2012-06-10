require 'spec_helper'

describe Variant, " instance methods" do
  before(:each) do
    @variant = create(:variant)
  end
  # OUT_OF_STOCK_QTY = 2
  # LOW_STOCK_QTY    = 6
  context ".sold_out?" do
    it 'should be sold out' do
      inventory   = create(:inventory, :count_on_hand => 100, :count_pending_to_customer => (100 - Variant::OUT_OF_STOCK_QTY))
      @variant    = create(:variant,   :inventory => inventory)
      @variant.sold_out?.should be_true
    end

    it 'should not be sold out' do
      inventory   = create(:inventory, :count_on_hand => 100, :count_pending_to_customer => (99 - Variant::OUT_OF_STOCK_QTY))
      @variant    = create(:variant,   :inventory => inventory)
      @variant.sold_out?.should be_false
    end

  end


  context ".low_stock?" do
      it 'should be low stock' do
        inventory   = create(:inventory, :count_on_hand => 100, :count_pending_to_customer => (101 - Variant::OUT_OF_STOCK_QTY))
        @variant    = create(:variant,   :inventory => inventory)
        @variant.low_stock?.should be_true
      end

      it 'should be low stock' do
        inventory   = create(:inventory, :count_on_hand => 100, :count_pending_to_customer => (100 - Variant::LOW_STOCK_QTY))
        @variant    = create(:variant,   :inventory => inventory)
        @variant.low_stock?.should be_true
      end

      it 'should not be low stock' do
        inventory   = create(:inventory, :count_on_hand => 100, :count_pending_to_customer => (99 - Variant::LOW_STOCK_QTY))
        @variant    = create(:variant,   :inventory => inventory)
        @variant.low_stock?.should be_false
      end
  end

  context ".display_stock_status(start = '(', finish = ')')" do
    it 'should be low stock' do

      inventory   = create(:inventory, :count_on_hand => 100, :count_pending_to_customer => (100 - Variant::LOW_STOCK_QTY))
      @variant    = create(:variant,   :inventory => inventory)
      @variant.display_stock_status.should == '(Low Stock)'
    end

    it 'should be sold out' do
      inventory   = create(:inventory, :count_on_hand => 100, :count_pending_to_customer => (100 - Variant::OUT_OF_STOCK_QTY))
      @variant    = create(:variant,   :inventory => inventory)
      @variant.display_stock_status.should == '(Sold Out)'
    end
  end

  context ".product_tax_rate(state_id, tax_time = Time.now)" do
    it 'should return the products tax rate for the given state' do
      tax_rate = create(:tax_rate)
      @variant.product.stubs(:tax_rate).returns(tax_rate)
      @variant.product_tax_rate(1).should == tax_rate
    end
  end

  context ".shipping_category_id" do
    it 'should return the products shipping_category' do
      @variant.product.stubs(:shipping_category_id).returns(32)
      @variant.shipping_category_id.should == 32
    end
  end

  context ".display_property_details(separator = '<br/>')" do
    # variant_properties.collect {|vp| [vp.property.display_name ,vp.description].join(separator) }
    it 'should show all property details' do
      property      = create(:property)
      property.stubs(:display_name).returns('Color')
      variant_prop1 = create(:variant_property, :property => property, :description => 'red')
      variant_prop2 = create(:variant_property, :property => property, :description => 'blue')
      @variant.variant_properties.push(variant_prop1)
      @variant.variant_properties.push(variant_prop2)
      @variant.display_property_details.should == 'Color: red<br/>Color: blue'
    end
  end

  context ".property_details(separator = ': ')" do
    it 'should show the property details' do
      property      = create(:property)
      property.stubs(:display_name).returns('Color')
      variant_prop1 = create(:variant_property, :property => property, :description => 'red')
      variant_prop2 = create(:variant_property, :property => property, :description => 'blue')
      @variant.variant_properties.push(variant_prop1)
      @variant.variant_properties.push(variant_prop2)
      @variant.property_details.should == ['Color: red', 'Color: blue']
    end
    it 'should show the property details without properties' do
      @variant.property_details.should == []
    end
  end

  context ".product_name" do
    it 'should return the variant name' do
      @variant.name = 'helloo'
      @variant.product.name = 'product says hello'
      @variant.product_name.should == 'helloo'
    end

    it 'should return the products name' do
        @variant.name = nil
        @variant.product.name = 'product says hello'
        @variant.product_name.should == 'product says hello'
    end

    it 'should return the products name and subname' do
        @variant.name = nil
        @variant.product.name = 'product says hello'
        @variant.stubs(:primary_property).returns  create(:variant_property, :description => 'pp_name')
        @variant.product_name.should == 'product says hello(pp_name)'
    end
  end

  context ".sub_name" do
    it 'should return the variants subname' do
        @variant.name = nil
        @variant.product.name = 'product says hello'
        @variant.stubs(:primary_property).returns  create(:variant_property, :description => 'pp_name')
        @variant.sub_name.should == '(pp_name)'
    end
  end

  context ".brand_name" do
    it 'should return the variants subname' do
        brand = create(:brand, :name => 'Nike')
        @variant.stubs(:brand).returns  brand
        @variant.stubs(:brand_id).returns  brand.id
        @variant.brand_name.should == 'Nike'
    end
    it 'should return the variants subname' do
      @brand = create(:brand, :name => 'Reabok')
      @product = create(:product, :brand => @brand)
        @variant.stubs(:brand).returns  nil
        @variant.stubs(:brand_id).returns  nil
        @variant.stubs(:product).returns @product
        @variant.brand_name.should == 'Reabok'
    end
  end

  context ".primary_property" do
    it 'should return the primary property' do
      property      = create(:property)
      property2      = create(:property)
      property.stubs(:display_name).returns('Color')
      variant_prop1 = create(:variant_property, :variant => @variant, :property => property, :primary => true)
      variant_prop2 = create(:variant_property, :variant => @variant, :property => property2, :primary => false)
      @variant.variant_properties.push(variant_prop2)
      @variant.variant_properties.push(variant_prop1)
      @variant.primary_property.should == variant_prop1
    end

    it 'should return the primary property' do
      property      = create(:property)
      property2      = create(:property)
      property.stubs(:display_name).returns('Color')
      variant_prop1 = create(:variant_property, :variant => @variant, :property => property, :primary => true)
      variant_prop2 = create(:variant_property, :variant => @variant, :property => property2, :primary => false)
      @variant.variant_properties.push(variant_prop1)
      @variant.variant_properties.push(variant_prop2)
      @variant.save
      @variant.primary_property.should == variant_prop1
    end
  end

  context ".name_with_sku" do
    it "should show name_with_sku" do
      @variant.name = 'helloo'
      @variant.sku = '54321'
      @variant.name_with_sku.should == 'helloo: 54321'
    end
  end

  context ".qty_to_add" do
    it "should return 0 for qty_to_add" do
      @variant.qty_to_add.should == 0
    end
  end

  context ".is_available?" do
    it "should be available" do

      inventory   = create(:inventory, :count_on_hand => 100, :count_pending_to_customer => 99)
      @variant    = create(:variant,   :inventory => inventory)
      @variant.save
      @variant.is_available?.should be_true
    end

    it "should not be available" do

      inventory   = create(:inventory, :count_on_hand => 100, :count_pending_to_customer => 100)
      @variant    = create(:variant,   :inventory => inventory)
      @variant.save
      @variant.is_available?.should be_false
    end
  end

  context ".count_available(reload_variant = true)" do
    it "should return count_available" do

      inventory   = create(:inventory, :count_on_hand => 100, :count_pending_to_customer => 99)
      @variant    = create(:variant,   :inventory => inventory)
      @variant.save
      @variant.is_available?.should be_true
    end
  end

  context ".add_count_on_hand(num)" do
    it "should update count_on_hand" do

      inventory   = create(:inventory, :count_on_hand => 100, :count_pending_to_customer => 99)
      @variant    = create(:variant,   :inventory => inventory)
      @variant.save
      @variant.add_count_on_hand(1)
      @variant.reload
      @variant.inventory.count_on_hand.should == 101
    end
  end

  context ".subtract_count_on_hand(num)" do
    it "should update count_on_hand" do

      inventory   = create(:inventory, :count_on_hand => 100, :count_pending_to_customer => 99)
      @variant    = create(:variant,   :inventory => inventory)
      @variant.save
      @variant.subtract_count_on_hand(1)
      @variant.reload
      @variant.inventory.count_on_hand.should == 99
    end
  end

  context ".add_pending_to_customer(num)" do
    it "should update count_on_hand" do
      inventory   = create(:inventory, :count_on_hand => 100, :count_pending_to_customer => 99)
      @variant    = create(:variant,   :inventory => inventory)
      @variant.save
      @variant.add_pending_to_customer(1)
      @variant.reload
      @variant.inventory.count_pending_to_customer.should == 100
    end
  end

  context ".subtract_pending_to_customer(num)" do
    it "should update subtract_pending_to_customer" do
      inventory   = create(:inventory, :count_on_hand => 100, :count_pending_to_customer => 99)
      @variant    = create(:variant,   :inventory => inventory)
      @variant.save
      @variant.subtract_pending_to_customer(1)
      @variant.reload
      @variant.inventory.count_pending_to_customer.should == 98
    end
  end

  context ".qty_to_add=(num)" do
    it "should update count_on_hand with qty_to_add" do

      inventory   = create(:inventory, :count_on_hand => 100, :count_pending_to_customer => 50)
      @variant    = create(:variant,   :inventory => inventory)
      @variant.qty_to_add = 12
      @variant.inventory.count_on_hand.should == 112
    end
  end
end
describe Variant, "instance method" do

  context ".quantity_purchaseable" do
    it 'should be quantity_purchaseable' do
      inventory   = create(:inventory, :count_on_hand => 100, :count_pending_to_customer => (98))
      @variant    = create(:variant,   :inventory => inventory)
      @variant.quantity_purchaseable.should == 2 - Variant::OUT_OF_STOCK_QTY
    end
    it 'should be quantity_purchaseable by an admin' do
      inventory   = create(:inventory, :count_on_hand => 100, :count_pending_to_customer => (98))
      @variant    = create(:variant,   :inventory => inventory)
      @variant.quantity_purchaseable(true).should == 2 - Variant::ADMIN_OUT_OF_STOCK_QTY
    end
  end

end

describe Variant, "#admin_grid(product, params = {})" do
  it "should return variants for a specific product" do
    product = create(:product)
    variant1 = create(:variant, :product => product)
    variant2 = create(:variant, :product => product)
    admin_grid = Variant.admin_grid(product)
    admin_grid.size.should == 2
    admin_grid.should == [variant1, variant2]
  end
end
