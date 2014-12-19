require 'spec_helper'

describe Product, ".instance methods with images" do
  before(:each) do
    @product = FactoryGirl.create(:product_with_image)
  end

  context "featured_image" do
    skip "test for featured_image"
    #it 'should return an image url' do
      # allow(@your_model).to receive(:save_attached_files).and_return(true)
      # Image.new :photo => File.new(Rails.root + 'spec/fixtures/images/rails.png')
    #  expect(@product.featured_image).not_to be_nil
    #end

  end
end



#def tax_rate(state_id, time = Time.zone.now)
#  TaxRate.where(["state_id = ? AND
#                         start_date <= ? AND
#                         (end_date > ? OR end_date IS NULL) AND
#                         active = ?", state_id,
#                                      time.to_date.to_s(:db),
#                                      time.to_date.to_s(:db),
#                                      true]).order('start_date DESC').first
#end

describe Product, ".tax_rate" do

  before(:each) do
    tr = TaxRate.new()
    tr.send(:expire_cache)
  end

  # use case tax rate end date is nil and the start_date < now
  it 'should return the tax rate' do
    Settings.tax_per_state_id = true
    tax_rate    = FactoryGirl.create(:tax_rate,
                          :state_id => 1,
                          :start_date => (Time.zone.now - 1.year),
                          :end_date => nil)
    product  = FactoryGirl.create(:product)
    expect(product.tax_rate(1, Time.zone.now)).to eq tax_rate
  end
  # use case tax rate end date is next month and the start_date < now
  it 'should return the tax rate' do
    tax_rate    = FactoryGirl.create(:tax_rate,
                          :state_id => 1,
                          :start_date => (Time.zone.now - 1.year),
                          :end_date => (Time.zone.now + 1.month))
    product  = FactoryGirl.create(:product)
    expect(product.tax_rate(1, Time.zone.now)).to eq tax_rate
  end
  # use case tax rate end date is one month ago and the start_date < now but the time was 2 months ago
  it 'should return the tax rate' do
    tax_rate    = FactoryGirl.create(:tax_rate,
                          :state_id => 1,
                          :start_date => (Time.zone.now - 1.year),
                          :end_date => (Time.zone.now - 1.month))
    Rails.cache.delete("TaxRate-active_at_ids-#{(Time.zone.now - 2.month).to_date}")
    product  = FactoryGirl.create(:product)
    expect(product.tax_rate(1, (Time.zone.now - 2.month))).to eq tax_rate
  end
  # there are no tax rates
  it 'should not return the tax rate' do
    product  = FactoryGirl.create(:product)
    expect(product.tax_rate(1, (Time.zone.now - 2.month))).to be_nil
  end
  # the tax rate starts next month
  it 'should not return any tax rates' do
    tax_rate    = FactoryGirl.create(:tax_rate,
                          :state_id   => 1,
                          :start_date => (Time.zone.now - 1.month),
                          :end_date   => nil)
    product  = FactoryGirl.create(:product)
    expect(product.tax_rate(1, (Time.zone.now - 2.month))).to be_nil
  end
  # the tax rate changes next month but is 5% now and next month will be 10%
  it 'should return any tax rates of 5%' do
    Settings.tax_per_state_id = true
    tax_rate    = FactoryGirl.create(:tax_rate,
                          :percentage => 5.0,
                          :state_id   => 1,
                          :start_date => (Time.zone.now - 1.year),
                          :end_date   => (Time.zone.now + 1.month))

    tax_rate2    = FactoryGirl.create(:tax_rate,
                          :percentage => 10.0,
                          :state_id   => 1,
                          :start_date => (Time.zone.now + 1.month),
                          :end_date   => (Time.zone.now + 1.year))
    product  = FactoryGirl.create(:product)
    expect(product.tax_rate(1)).to eq tax_rate
  end

  it 'should tax the countries tax rate' do
    Settings.tax_per_state_id = false
    tax_rate    = FactoryGirl.create(:tax_rate,
                          :percentage => 5.0,
                          :country_id   => 1,
                          :start_date => (Time.zone.now - 1.year),
                          :end_date   => (Time.zone.now + 1.month))
    product  = FactoryGirl.create(:product)
    expect(product.tax_rate(1)).to eq tax_rate
    Settings.tax_per_state_id = true
  end

end

describe Product, ".instance methods" do
  context 'with three variants' do
    before(:each) do
      product  = FactoryGirl.create(:product)
      @previous_master = FactoryGirl.create(:variant, :product => product, :master => true, :price => 15.05, :deleted_at => (Time.zone.now - 1.day ))
      FactoryGirl.create(:variant, :product => product, :master => true, :price => 15.01)
      FactoryGirl.create(:variant, :product => product, :master => false, :price => 10.00)
      @product  = Product.find(product.id)
    end

    context "featured_image" do

      it 'should return no_image url' do
        expect(@product.featured_image).to        eq 'no_image_small.jpg'
        expect(@product.featured_image(:mini)).to eq 'no_image_mini.jpg'
      end

    end

    context ".price" do
      it 'should return the lowest price' do
        expect(@product.price).to eq 10.00
      end
    end

    context ".set_keywords=(value)" do
      it 'should set keywords' do
        @product.set_keywords             =  'hi, my, name, is, Dave'
        expect(@product.product_keywords).to  eq ['hi', 'my', 'name', 'is', 'Dave']
        expect(@product.set_keywords).to      eq 'hi, my, name, is, Dave'
      end
    end

    context ".display_price_range(j = ' to ')" do
      it 'should return the price range' do
        expect(@product.display_price_range).to eq '10.0 to 15.01'
      end
    end

    context ".price_range" do
      it 'should return the price range' do
        expect(@product.price_range).to eq [10.0, 15.01]
      end
    end

    context ".price_range?" do
      it 'should return the price range' do
        expect(@product.price_range?).to be true
      end
    end
  end

  context 'without variants' do
    before(:each) do
      @product  = FactoryGirl.create(:product)
    end

    context '.available?' do
      context 'with a shipping rate but no inventory' do
        it 'should be false' do
          inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: 100)
          @variant    = FactoryGirl.create(:variant, product: @product, inventory: inventory)
          FactoryGirl.create(:shipping_rate, shipping_category: @product.shipping_category)
          expect(@product.available?).to be false
        end
      end

      context 'with inventory but no shipping rate' do
        it 'should be false' do
          inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: 90)
          @variant    = FactoryGirl.create(:variant, product: @product, inventory: inventory)
          expect(@product.available?).to be false
        end
      end

      context 'with a shipping rate & inventory' do
        it 'should be true' do
          inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: 90)
          @variant    = FactoryGirl.create(:variant, product: @product, inventory: inventory)
          FactoryGirl.create(:shipping_rate, shipping_category: @product.shipping_category)
          expect(@product.available?).to be true
        end
      end
    end

    context '.has_shipping_method?' do
      it 'should be false without a shipping rate' do
        expect(@product.has_shipping_method?).to be false
      end

      it 'should be true with a shipping rate' do
        inventory   = FactoryGirl.create(:inventory, count_on_hand: 100, count_pending_to_customer: 90)
        @variant    = FactoryGirl.create(:variant, product: @product, inventory: inventory)
        FactoryGirl.create(:shipping_rate, shipping_category: @product.shipping_category)
        expect(@product.has_shipping_method?).to be true
      end
    end
  end
end


describe Product, "class methods" do

  context "#standard_search(args)" do
    it "should search products" do
      product1  = FactoryGirl.create(:product, meta_keywords: 'no blah', name: 'blah')
      product2  = FactoryGirl.create(:product, meta_keywords: 'tester blah')
      Product.any_instance.stubs(:ensure_available).returns(true)
      product1.activate!
      product2.activate!
      args = 'tester'
      products = Product.standard_search(args)
      expect(products.include?(product1)).to be false
      expect(products.include?(product2)).to be true
    end
  end

  context '.activate!' do
    it "should activate the product " do
      product = FactoryGirl.create(:product)
      variant = FactoryGirl.create(:variant, product: product)
      variant.add_count_on_hand(1)
      product.activate!
      product.reload
      expect(product.active?).to be true
    end

    it "should not activate a product without variants" do
      product = FactoryGirl.create(:product)
      product.activate!
      product.reload
      expect(product.active?).to be false
    end

    it "should not activate a product without inventory" do
      product = FactoryGirl.create(:product)
      variant = FactoryGirl.create(:variant, product: product)
      variant.inventory.count_on_hand = 0
      variant.inventory.count_pending_to_customer = 0
      variant.inventory.save!
      product.activate!
      product.reload
      expect(product.active?).to be false
    end
  end

  context "#featured" do
    skip "test for featured"
  end

  context "#admin_grid(params = {}, active_state = nil)" do

    it "should return Products " do
      product1 = FactoryGirl.create(:product, deleted_at: (Time.zone.now - 2.second))
      product2 = FactoryGirl.create(:product, deleted_at: (Time.zone.now - 2.second))
      Product.any_instance.stubs(:ensure_available).returns(true)
      product1.activate!
      product2.activate!
      admin_grid = Product.admin_grid({}, true)
      expect(admin_grid.size).to eq 2
      expect(admin_grid.include?(product1)).to be true
      expect(admin_grid.include?(product2)).to be true
    end
    it "should return deleted Products " do
      product1 = FactoryGirl.create(:product, deleted_at: (Time.zone.now - 2.seconds))
      product2 = FactoryGirl.create(:product, deleted_at: (Time.zone.now - 2.seconds))
      admin_grid = Product.admin_grid({}, false)
      expect(admin_grid.size).to eq 2
      expect(admin_grid.include?(product1)).to be true
      expect(admin_grid.include?(product2)).to be true
    end
  end
end
