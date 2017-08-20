require 'spec_helper'

describe Variant, " instance methods" do
  before(:each) do
    @variant = FactoryGirl.create(:variant)
  end
  # OUT_OF_STOCK_QTY = 2
  # LOW_STOCK_QTY    = 6
  context ".sold_out?" do
    it 'should be sold out' do
      inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: (100 - Variant::OUT_OF_STOCK_QTY))
      @variant    = FactoryGirl.create(:variant,   inventory: inventory)
      expect(@variant.sold_out?).to be true
    end

    it 'should not be sold out' do
      inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: (99 - Variant::OUT_OF_STOCK_QTY))
      @variant    = FactoryGirl.create(:variant,   inventory: inventory)
      expect(@variant.sold_out?).to be false
    end

  end


  context ".low_stock?" do
      it 'should be low stock' do
        inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: (101 - Variant::OUT_OF_STOCK_QTY))
        @variant    = FactoryGirl.create(:variant,   inventory: inventory)
        expect(@variant.low_stock?).to be true
      end

      it 'should be low stock' do
        inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: (100 - Variant::LOW_STOCK_QTY))
        @variant    = FactoryGirl.create(:variant,   inventory: inventory)
        expect(@variant.low_stock?).to be true
      end

      it 'should not be low stock' do
        inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: (99 - Variant::LOW_STOCK_QTY))
        @variant    = FactoryGirl.create(:variant,   inventory: inventory)
        expect(@variant.low_stock?).to be false
      end
  end

  context ".display_stock_status(start = '(', finish = ')')" do
    it 'should be low stock' do

      inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: (100 - Variant::LOW_STOCK_QTY))
      @variant    = FactoryGirl.create(:variant,   inventory: inventory)
      expect(@variant.display_stock_status).to eq '(Low Stock)'
    end

    it 'should be sold out' do
      inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: (100 - Variant::OUT_OF_STOCK_QTY))
      @variant    = FactoryGirl.create(:variant,   inventory: inventory)
      expect(@variant.display_stock_status).to eq '(Sold Out)'
    end
  end

  context ".product_tax_rate(state_id, tax_time = Time.now)" do
    it 'should return the products tax rate for the given state' do
      tax_rate = FactoryGirl.create(:tax_rate)
      @variant.product.stubs(:tax_rate).returns(tax_rate)
      expect(@variant.product_tax_rate(1)).to eq tax_rate
    end
  end

  context ".shipping_category_id" do
    it 'should return the products shipping_category' do
      @variant.product.stubs(:shipping_category_id).returns(32)
      expect(@variant.shipping_category_id).to eq 32
    end
  end

  context ".display_property_details(separator = '<br/>')" do
    # variant_properties.collect {|vp| [vp.property.display_name ,vp.description].join(separator) }
    it 'should show all property details' do
      property      = FactoryGirl.create(:property)
      property.stubs(:display_name).returns('Color')
      variant_prop1 = FactoryGirl.create(:variant_property, property: property, :description => 'red')
      variant_prop2 = FactoryGirl.create(:variant_property, property: property, :description => 'blue')
      @variant.variant_properties.push(variant_prop1)
      @variant.variant_properties.push(variant_prop2)
      expect(@variant.display_property_details).to eq 'Color: red<br/>Color: blue'
    end
  end

  context ".property_details(separator = ': ')" do
    it 'should show the property details' do
      property      = FactoryGirl.create(:property)
      property.stubs(:display_name).returns('Color')
      variant_prop1 = FactoryGirl.create(:variant_property, property: property, :description => 'red')
      variant_prop2 = FactoryGirl.create(:variant_property, property: property, :description => 'blue')
      @variant.variant_properties.push(variant_prop1)
      @variant.variant_properties.push(variant_prop2)
      expect(@variant.property_details).to eq ['Color: red', 'Color: blue']
    end
    it 'should show the property details without properties' do
      expect(@variant.property_details).to eq []
    end
  end

  context ".product_name" do
    it 'should return the variant name' do
      @variant.name = 'helloo'
      @variant.product.name = 'product says hello'
      expect(@variant.product_name).to eq 'helloo'
    end

    it 'should return the products name' do
        @variant.name = nil
        @variant.product.name = 'product says hello'
        expect(@variant.product_name).to eq 'product says hello'
    end

    it 'should return the products name and subname' do
        @variant.name = nil
        @variant.product.name = 'product says hello'
        @variant.stubs(:primary_property).returns  FactoryGirl.create(:variant_property, :description => 'pp_name')
        expect(@variant.product_name).to eq 'product says hello - pp_name'
    end
  end

  context ".sub_name" do
    it 'should return the variants subname' do
        @variant.name = nil
        @variant.product.name = 'product says hello'
        @variant.stubs(:primary_property).returns  FactoryGirl.create(:variant_property, :description => 'pp_name')
        expect(@variant.sub_name).to eq 'pp_name'
    end
  end

  context ".brand_name" do
    it 'should return the variants subname' do
      brand     = FactoryGirl.create(:brand, name: 'Reabok')
      @product  = FactoryGirl.create(:product, brand: brand)
      @variant.stubs(:product).returns @product
      expect(@variant.brand_name).to eq 'Reabok'
    end
  end

  context ".primary_property" do
    it 'should return the primary property' do
      property      = FactoryGirl.create(:property)
      property2      = FactoryGirl.create(:property)
      property.stubs(:display_name).returns('Color')
      variant_prop1 = FactoryGirl.create(:variant_property, variant: @variant, property: property, primary: true)
      variant_prop2 = FactoryGirl.create(:variant_property, variant: @variant, property: property2, primary: false)
      @variant.variant_properties.push(variant_prop2)
      @variant.variant_properties.push(variant_prop1)
      expect(@variant.primary_property).to eq variant_prop1
    end

    it 'should return the primary property' do
      property      = FactoryGirl.create(:property)
      property2      = FactoryGirl.create(:property)
      property.stubs(:display_name).returns('Color')
      variant_prop1 = FactoryGirl.create(:variant_property, variant: @variant, property: property, primary: true)
      variant_prop2 = FactoryGirl.create(:variant_property, variant: @variant, property: property2, primary: false)
      @variant.variant_properties.push(variant_prop1)
      @variant.variant_properties.push(variant_prop2)
      @variant.save
      expect(@variant.primary_property).to eq variant_prop1
    end
  end

  context ".name_with_sku" do
    it "should show name_with_sku" do
      @variant.name = 'helloo'
      @variant.sku = '54321'
      expect(@variant.name_with_sku).to eq 'helloo: 54321'
    end
  end

  context ".qty_to_add" do
    it "should return 0 for qty_to_add" do
      expect(@variant.qty_to_add).to eq 0
    end
  end

  context ".is_available?" do
    it "should be available" do

      inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: 99)
      @variant    = FactoryGirl.create(:variant,   inventory: inventory)
      @variant.save
      expect(@variant.is_available?).to be true
    end

    it "should not be available" do

      inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: 100)
      @variant    = FactoryGirl.create(:variant,   inventory: inventory)
      @variant.save
      expect(@variant.is_available?).to be false
    end
  end

  context ".count_available(reload_variant = true)" do
    it "should return count_available" do

      inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: 99)
      @variant    = FactoryGirl.create(:variant,   inventory: inventory)
      @variant.save
      expect(@variant.is_available?).to be true
    end
  end

  context ".add_count_on_hand(num)" do
    it "should update count_on_hand" do

      inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: 99)
      @variant    = FactoryGirl.create(:variant,   inventory: inventory)
      @variant.save
      @variant.add_count_on_hand(1)
      @variant.reload
      expect(@variant.inventory.count_on_hand).to eq 101
    end
  end

  context ".subtract_count_on_hand(num)" do
    it "should update count_on_hand" do

      inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: 99)
      @variant    = FactoryGirl.create(:variant,   inventory: inventory)
      @variant.save
      @variant.subtract_count_on_hand(1)
      @variant.reload
      expect(@variant.inventory.count_on_hand).to eq 99
    end
  end

  context ".add_pending_to_customer(num)" do
    it "should update count_on_hand" do
      inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: 99)
      @variant    = FactoryGirl.create(:variant,   inventory: inventory)
      @variant.save
      @variant.add_pending_to_customer(1)
      @variant.reload
      expect(@variant.inventory.count_pending_to_customer).to eq 100
    end
  end

  context ".subtract_pending_to_customer(num)" do
    it "should update subtract_pending_to_customer" do
      inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: 99)
      @variant    = FactoryGirl.create(:variant,   inventory: inventory)
      @variant.save
      @variant.subtract_pending_to_customer(1)
      @variant.reload
      expect(@variant.inventory.count_pending_to_customer).to eq 98
    end
  end

  context ".qty_to_add=(num)" do
    it "should update count_on_hand with qty_to_add" do

      inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: 50)
      @variant    = FactoryGirl.create(:variant,   inventory: inventory)
      @variant.qty_to_add = 12
      expect(@variant.inventory.count_on_hand).to eq 112
    end
  end
end
describe Variant, "instance method" do

  context ".quantity_purchaseable" do
    it 'should be quantity_purchaseable' do
      inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: (98))
      @variant    = FactoryGirl.create(:variant,   inventory: inventory)
      expect(@variant.quantity_purchaseable).to eq 2 - Variant::OUT_OF_STOCK_QTY
    end
    it 'should be quantity_purchaseable by an admin' do
      inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: (98))
      @variant    = FactoryGirl.create(:variant,   inventory: inventory)
      expect(@variant.quantity_purchaseable(true)).to eq 2 - Variant::ADMIN_OUT_OF_STOCK_QTY
    end
  end

end

describe Variant, "#admin_grid(product, params = {})" do
  it "should return variants for a specific product" do
    product = FactoryGirl.create(:product)
    variant1 = FactoryGirl.create(:variant, product: product)
    variant2 = FactoryGirl.create(:variant, product: product)
    admin_grid = Variant.admin_grid(product)
    expect(admin_grid.size).to eq 2
    expect(admin_grid.include?(variant1)).to be true
    expect(admin_grid.include?(variant2)).to be true
  end
end
