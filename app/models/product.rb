# == Schema Information
#
# Table name: products
#
#  id                   :integer(4)      not null, primary key
#  name                 :string(255)     not null
#  description          :text
#  product_keywords     :text
#  product_type_id      :integer(4)      not null
#  prototype_id         :integer(4)
#  shipping_category_id :integer(4)      not null
#  permalink            :string(255)     not null
#  available_at         :datetime
#  deleted_at           :datetime
#  meta_keywords        :string(255)
#  meta_description     :string(255)
#  featured             :boolean(1)      default(FALSE)
#  created_at           :datetime
#  updated_at           :datetime
#  description_markup   :text
#  active               :boolean(1)      default(FALSE)
#  brand_id             :integer(4)
#

class VariantRequiredError < StandardError; end

class Product < ActiveRecord::Base
  extend FriendlyId
  friendly_id :permalink

  serialize :product_keywords, Array

  attr_accessor :available_shipping_rates # these the the shipping rates per the shipping address on the order

  belongs_to :brand
  belongs_to :product_type
  belongs_to :prototype
  belongs_to :shipping_category

  has_many :product_properties
  has_many :properties,          :through => :product_properties

  has_many :variants
  has_many :images, :as         => :imageable,
                    :order      => :position,
                    :dependent  => :destroy

  has_many :active_variants,
    :class_name => 'Variant',
    :conditions => ["variants.deleted_at IS NULL", true]

  before_validation :sanitize_data
  before_validation :not_active_on_create!, :on => :create
  before_save :create_content

  accepts_nested_attributes_for :variants,            :reject_if => proc { |attributes| attributes['sku'].blank? }
  accepts_nested_attributes_for :product_properties,  :reject_if => proc { |attributes| attributes['description'].blank? }, :allow_destroy => true
  accepts_nested_attributes_for :images,              :reject_if => proc { |t| (t['photo'].nil? && t['photo_from_link'].blank?) }, :allow_destroy => true

  validates :shipping_category_id,  :presence => true
  validates :product_type_id,       :presence => true
  validates :name,                  :presence => true,   :length => { :maximum => 165 }
  validates :description_markup,    :presence => true,   :length => { :maximum => 2255 },     :if => :active
  validates :meta_keywords,         :presence => true,        :length => { :maximum => 255 }, :if => :active
  validates :meta_description,      :presence => true,        :length => { :maximum => 255 }, :if => :active
  validates :permalink,             :uniqueness => true,      :length => { :maximum => 150 }

  def hero_variant
    active_variants.detect{|v| v.master } || active_variants.first
  end

  # gives you the tax rate for the give state_id and the time.
  #  Tax rates can change from year to year so Time is a factor
  #
  # @param [Integer] state.id
  # @param [Optional Time] Time now if no value is passed in
  # @return [TaxRate] TaxRate for the state at a given time
  def tax_rate(region_id, time = Time.zone.now)
    TaxRate.for_region(region_id).at(time).active.order('start_date DESC').first
  end

  # Image that is featured for your product
  #
  # @param [Optional Symbol] the size of the image expected back
  # @return [String] name of the file to show from the public folder
  def featured_image(image_size = :small)
    images.first ? images.first.photo.url(image_size) : "no_image_#{image_size.to_s}.jpg"
  end

  # Price of cheapest variant
  #
  # @param [none] the size of the image expected back
  # @return [Decimal] price
  def price
    active_variants.present? ? price_range.first : raise( VariantRequiredError )
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
    product_keywords ? product_keywords.join(', ') : ''
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
    @price_range = active_variants.minmax {|a,b| a.price <=> b.price }.map(&:price)
  end

  # Answers if the product has a price range or just one price.
  #   if there is more than one price returns true
  #
  # @param [none]
  # @return [Boolean] true == there is more than one price
  def price_range?
    !(price_range.first == price_range.last)
  end

  # Solr searching for products
  #
  # @param [args]
  # @param [params]  :rows, :page
  # @return [ Product ]
  def self.standard_search(args, params = {:page => 1, :per_page => 15})
      Product.includes( [:properties, :images]).active.
              where(['products.name LIKE ? OR products.meta_keywords LIKE ?', "%#{args}%", "%#{args}%"]).
              paginate(params)
  end

  # This returns the first featured product in the database,
  # if there isn't a featured product the first product will be returned
  #
  # @param [none]
  # @return [ Product ]
  def self.featured
    product = where({ :products => {:featured => true} } ).includes(:images).first
    product ? product : includes(:images).where(['products.deleted_at IS NULL']).first
  end

  def self.active
    where("products.deleted_at IS NULL OR products.deleted_at > ?", Time.zone.now)
    #  Add this line if you want the available_at to function
    #where("products.available_at IS NULL OR products.available_at >= ?", Time.zone.now)
  end

  def active(at = Time.zone.now)
    deleted_at.nil? || deleted_at >= at
  end
  def active?(at = Time.zone.now)
    active(at)
  end

  def activate!
    self.deleted_at = nil
    save
  end

  def available?
    active
  end

  # returns the brand's name or a blank string
  #  ex: obj.brand_name => 'Nike'
  #
  # @param [none]
  # @return [String]
  def brand_name
    brand_id ? brand.name : ''
  end
  # paginated results from the admin products grid
  #
  # @param [Optional params]
  # @param [Optional Boolean] the state of the product you are searching (active == true)
  # @return [ Array[Product] ]
  def self.admin_grid(params = {}, active_state = nil)
    grid = includes(:variants).
                deleted_at_filter(active_state).
                name_filter(params[:name]).
                product_type_filter( params[:product_type_id] ).
                shipping_category_filter(params[:shipping_category_id]).
                available_at_gt_filter(params[:available_at_gt]).
                available_at_lt_filter(params[:available_at_lt])
  end

  private

    def self.available_at_lt_filter(available_at_lt)
      if available_at_lt.present?
        where("products.available_at < ?", available_at_lt)
      else
        scoped
      end
    end

    def self.available_at_gt_filter(available_at_gt)
      if available_at_gt.present?
        where("products.available_at > ?", available_at_gt)
      else
        scoped
      end
    end
    def self.shipping_category_filter(shipping_category_id)
      if shipping_category_id.present?
        where("products.shipping_category_id = ?", shipping_category_id)
      else
        scoped
      end
    end

    def self.product_type_filter(product_type_id)
      if product_type_id.present?
        where("products.product_type_id = ?", product_type_id)
      else
        scoped
      end
    end

    def self.name_filter(name)
      if name.present?
        where("products.name LIKE ?", "#{name}%")
      else
        scoped
      end
    end

    def self.deleted_at_filter(active_state)
      if active_state
        active
      elsif active_state == false##  note nil != false
        where(['products.deleted_at IS NOT NULL AND products.deleted_at <= ?', Time.zone.now.to_s(:db)])
      else
        scoped
      end
    end
    def create_content
      self.description = BlueCloth.new(self.description_markup).to_html unless self.description_markup.blank?
    end

    def not_active_on_create!
      self.deleted_at = Time.zone.now
    end

    # if the permalink is not filled in set it equal to the name
    def sanitize_data
      sanitize_permalink
      assign_meta_keywords  if meta_keywords.blank? && description
      sanitize_meta_description
    end

    def sanitize_permalink
      self.permalink = name if permalink.blank? && name
      self.permalink = permalink.squeeze(" ").strip.gsub(' ', '-') if permalink
    end

    def sanitize_meta_description
      if name && description.present? && meta_description.blank?
        self.meta_description = [name.first(55), description.remove_hyper_text.first(197)].join(': ')
      end
    end

    def assign_meta_keywords
      self.meta_keywords =  [name.first(55),
                            description.
                            remove_non_alpha_numeric.           # remove non-alpha numeric
                            remove_hyper_text.                  # remove hyper text
                            remove_words_less_than_x_characters. # remove words less than 2 characters
                            first(197)                       # limit to 197 characters
                            ].join(': ')
    end
end

## If you want to use SOLR search uncomment the following:
=begin
    Product.class_eval do
      searchable do
        text    :name, :default_boost => 2
        text      :product_keywords#, :multiple => true
        text      :description
        time      :deleted_at
      end

      def self.standard_search(args, params = {})
        params[:rows] ||= 15
        params[:page] ||= 1
        Product.search(:include => [:properties, :images]) do
          keywords(args)
          any_of do
            with(:deleted_at).greater_than(Time.zone.now)
            with(:deleted_at, nil)
          end
          paginate :page => params[:page].to_i, :per_page => params[:rows].to_i
        end
      end
    end
=end
