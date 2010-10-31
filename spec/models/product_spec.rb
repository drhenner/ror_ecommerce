require 'spec_helper'

describe Product, ".instance methods with images" do
  before(:each) do
    @product = Factory(:product_with_image)
  end
  
  context "featured_image" do
    pending "test for featured_image"
    #it 'should return an image url' do
      # @your_model.should_receive(:save_attached_files).and_return(true)
      # Image.new :photo => File.new(Rails.root + 'spec/fixtures/images/rails.png')
    #  @product.featured_image.should_not be_nil
    #end

  end
end

describe Product, ".instance methods" do
  before(:each) do
    product  = Factory(:product)
    @previous_master = Factory(:variant, :product => product, :master => true, :price => 15.05, :deleted_at => (Time.zone.now - 1.day ))
    Factory(:variant, :product => product, :master => true, :price => 15.01)
    Factory(:variant, :product => product, :master => false, :price => 10.00)
    @product  = Product.find(product.id)
  end
  
  context "featured_image" do

    it 'should return no_image url' do
      @product.featured_image.should == 'no_image.jpg'
    end

  end

  #def tax_rate(state_id, time = Time.zone.now)
  #  self.tax_status.tax_rates.where(["state_id = ? AND 
  #                         start_date <= ? AND
  #                         (end_date > ? OR end_date IS NULL) AND
  #                         active = ?", state_id, 
  #                                      time.to_date.to_s(:db), 
  #                                      time.to_date.to_s(:db), 
  #                                      true]).order('start_date DESC').first
  #end
  
  context ".tax_rate" do
    it 'should return the tax rate' 
  end
  
  context ".price" do
    it 'should return the master price' do
      @product.price.should == 15.01
    end
  end

  context ".set_keywords=(value)" do
    it 'should set keywords' do
      @product.set_keywords             =  'hi, my, name, is, Dave'
      @product.product_keywords.should  == ['hi', 'my', 'name', 'is', 'Dave']
      @product.set_keywords.should      == 'hi, my, name, is, Dave'
    end
  end

  context ".display_price_range(j = ' to ')" do
    it 'should return the price range' do
      @product.display_price_range.should == '10.0 to 15.01'
    end
  end

  context ".price_range" do
    it 'should return the price range' do
      @product.price_range.should == [10.0, 15.01]
    end
  end

  context ".last_master_variant" do
    it 'should return the previous master variant' do
      @product.last_master_variant.id.should == @previous_master.id
    end
  end
end


describe Product, "class methods" do

  context "#standard_search(args, params)" do
    pending "test for standard_search(args, params)"
  end

  context "#featured" do
    pending "test for featured"
  end

  context "#admin_grid(params = {}, active_state = nil)" do
    pending "test for "
  end
end