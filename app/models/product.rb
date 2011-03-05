class Product < ActiveRecord::Base
  has_friendly_id :permalink, :use_slug => false

  serialize :product_keywords, Array

  attr_accessor :available_shipping_rates # these the the shipping rates per the shipping address on the order

  searchable do
    text    :name, :default_boost => 2
    text      :product_keywords#, :multiple => true
    text      :description
    time      :deleted_at
  end
  #Sunspot.setup(Rehab) do
  #  text :addiction
  #  integer :relapses
  #  float :relapse_average
  #  time :admitted_at
  #  string :cure do
  #    addiction.gsub(/(darkness|clouds|shadows)/, 'sunshine')
  #  end
  #end

  belongs_to :product_type
  belongs_to :prototype
  belongs_to :shipping_category
  belongs_to :tax_status

  has_many :product_properties
  has_many :properties,          :through => :product_properties

  has_many :variants
  has_many :images, :as         => :imageable,
                    :order      => :position,
                    :dependent  => :destroy

  has_one :master_variant,
    :class_name => 'Variant',
    :conditions => ["variants.master = ? AND variants.deleted_at IS NULL", true]

  has_many :active_variants,
    :class_name => 'Variant',
    :conditions => ["variants.deleted_at IS NULL", true]

  has_many :inactive_master_variants,
    :class_name => 'Variant',
    :conditions => ["variants.deleted_at IS NOT NULL AND variants.master = ? ", true]
  accepts_nested_attributes_for :variants
  accepts_nested_attributes_for :product_properties, :reject_if => proc { |attributes| attributes['description'].blank? }

  accepts_nested_attributes_for :images, :reject_if => lambda { |t| t['photo'].nil? }

  validates :shipping_category_id,  :presence => true
  validates :tax_status_id,         :presence => true
  validates :product_type_id,       :presence => true
  validates :prototype_id,          :presence => true
  validates :name,                  :presence => true, :length => { :maximum => 165 }
  validates :description,           :presence => true, :length => { :maximum => 2255 }
  validates :meta_keywords,         :presence => true,       :length => { :maximum => 255 }
  validates :meta_description,      :presence => true,       :length => { :maximum => 255 }

  # gives you the tax rate for the give state_id and the time.
  #  Tax rates can change from year to year so Time is a factor
  #
  # @param [Integer] state.id
  # @param [Optional Time] Time now if no value is passed in
  # @return [TaxRate] TaxRate for the state at a given time
  def tax_rate(state_id, time = Time.zone.now)
    self.tax_status.tax_rates.where(["state_id = ? AND
                           start_date <= ? AND
                           (end_date > ? OR end_date IS NULL) AND
                           active = ?", state_id,
                                        time.to_date.to_s(:db),
                                        time.to_date.to_s(:db),
                                        true]).order('start_date DESC').first
  end

  # Image that is featured for your product
  #
  # @param [Optional Symbol] the size of the image expected back
  # @return [String] name of the file to show from the public folder
  def featured_image(image_size = :small)
    images.first ? images.first.photo.url(image_size) : "no_image_#{image_size.to_s}.jpg"
  end

  # Price of master variant or last_master_variant if all the variants are inactive
  #
  # @param [none] the size of the image expected back
  # @return [Decimal] price
  def price
    master_variant ? master_variant.price : last_master_variant.price
  end

  # in the admin form this is the method called when the form is submitted, The method sets
  # the product_keywords attribute to an array of these values
  #
  # @param [String] value for set_keywords in a products form
  # @return [none]
  def set_keywords=(value)
    self.product_keywords = value ? value.split(',').map{|w| w.strip} : []
  end

  # method used by forms to set the array of keywords separated by a comma
  #
  # @param [none]
  # @return [String] product_keywords separated by comma
  def set_keywords
    self.product_keywords ? self.product_keywords.join(', ') : ''
  end

  # range of the product prices in plain english
  #
  # @param [Optional String] separator between the low and high price
  # @return [String] Low price + separator + High price
  def display_price_range(j = ' to ')
    price_range.join(j)
  end

  # range of the product prices (Just teh low and high price) as an array
  #
  # @param [none]
  # @return [Array] [Low price, High price]
  def price_range
    return @price_range if @price_range
    return @price_range = ['N/A', 'N/A'] if active_variants.empty?
    @price_range = active_variants.inject([active_variants.first.price, active_variants.first.price]) do |a, variant|
      a[0] = variant.price if variant.price < a[0]
      a[1] = variant.price if variant.price > a[1]
      a
    end
  end

  # Answers if the product has a price range or just one price.
  #   if there is more than one price returns true
  #
  # @param [none]
  # @return [Boolean] true == there is more than one price
  def price_range?
    !(price_range.first == price_range.last)
  end

  # find the last master variant that was inactivated
  #
  # @param [none]
  # @return [Variant or nil] variant of the last master variant that was inactivated
  def last_master_variant
    inactive_master_variants.try(:last)
  end


  # Solr searching for products
  #
  # @param [args]
  # @param [params]  :rows, :page
  # @return [ Product ]
  def self.standard_search(args, params)
    Product.search(:include => [:properties, :images]) do
      keywords(args)
      any_of do
        with(:deleted_at).greater_than(Time.zone.now)
        with(:deleted_at, nil)
      end
      paginate :page => params[:page], :per_page => params[:rows]#params[:page], :per_page => params[:rows]
    end
  end

  # This returns the first featured product in the database,
  # if there isn't a featured product the first product will be returned
  #
  # @param [none]
  # @return [ Product ]
  def self.featured
    product = Product.where({ :products => {:featured => true} } ).includes(:images).first
    product ? product : Product.includes(:images).where(['products.deleted_at IS NULL']).first
  end

  # paginated results from the admin products grid
  #
  # @param [Optional params]
  # @param [Optional Boolean] the state of the product you are searching (active == true)
  # @return [ Array[Product] ]
  def self.admin_grid(params = {}, active_state = nil)

    params[:page] ||= 1
    params[:rows] ||= SETTINGS[:admin_grid_rows]

    grid = Product.includes(:variants)#paginate({:page => params[:page]})
    grid = grid.where(['products.deleted_at IS NOT NULL AND products.deleted_at > ?', Time.now.to_s(:db)])  if active_state == false##  note nil != false
    grid = grid.where(['products.deleted_at IS NULL     OR  products.deleted_at < ?', Time.now.to_s(:db)])  if active_state == true
    #grid.includes(:variants)
    grid = grid.where("products.name = ?",                 params[:name])                  if params[:name].present?
    grid = grid.where("products.product_type_id = ?",      params[:product_type_id])       if params[:product_type_id].present?
    grid = grid.where("products.shipping_category_id = ?", params[:shipping_category_id])  if params[:shipping_category_id].present?
    grid = grid.where("products.available_at > ?",         params[:available_at_gt])       if params[:available_at_gt].present?
    grid = grid.where("products.available_at < ?",         params[:available_at_lt])       if params[:available_at_lt].present?
    grid = grid.order("#{params[:sidx]} #{params[:sord]}").paginate(:page => params[:page], :per_page => params[:rows])
  end
end
