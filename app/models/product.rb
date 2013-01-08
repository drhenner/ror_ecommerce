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

class Product < ActiveRecord::Base
  has_friendly_id :permalink, :use_slug => false

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

  has_one :master_variant,
    :class_name => 'Variant',
    :conditions => ["variants.master = ? AND variants.deleted_at IS NULL", true]

  has_many :active_variants,
    :class_name => 'Variant',
    :conditions => ["variants.deleted_at IS NULL", true]

  has_many :inactive_master_variants,
    :class_name => 'Variant',
    :conditions => ["variants.deleted_at IS NOT NULL AND variants.master = ? ", true]

  before_validation :sanitize_data
  before_save :create_content

  accepts_nested_attributes_for :variants, :reject_if => proc { |attributes| attributes['sku'].blank? }
  accepts_nested_attributes_for :product_properties, :reject_if => proc { |attributes| attributes['description'].blank? }, :allow_destroy => true

  accepts_nested_attributes_for :images, :reject_if => lambda { |t| (t['photo'].nil? && t['photo_from_link'].blank?) }, :allow_destroy => true

  validates :shipping_category_id,  :presence => true
  validates :product_type_id,       :presence => true
  validates :permalink, :uniqueness => true, :length => { :maximum => 150 }
  validates :name,                  :presence => true, :length => { :maximum => 165 }
  validates :description_markup,    :presence => true, :length => { :maximum => 2255 },     :if => :active
  validates :meta_keywords,         :presence => true,       :length => { :maximum => 255 }, :if => :active
  validates :meta_description,      :presence => true,       :length => { :maximum => 255 }, :if => :active

  def hero_variant
    master_variant ? master_variant : variants.limit(1).first
  end

  # gives you the tax rate for the give state_id and the time.
  #  Tax rates can change from year to year so Time is a factor
  #
  # @param [Integer] state.id
  # @param [Optional Time] Time now if no value is passed in
  # @return [TaxRate] TaxRate for the state at a given time
  def tax_rate(state_id, time = Time.zone.now)
    TaxRate.where(["#{ Settings.tax_per_state_id ? 'state_id' : 'country_id'} = ? AND
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
      Product.includes( [:properties, :images]).
              where(['products.name LIKE ? OR products.meta_keywords LIKE ?', "%#{args}%", "%#{args}%"]).
              where(['products.deleted_at IS NULL OR products.deleted_at > ?', Time.zone.now]).
              paginate :page => params[:page].to_i, :per_page => params[:rows].to_i
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
    deleted_at.nil? || deleted_at > at
  end
  def active?(at = Time.zone.now)
    active(at)
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

    params[:page] ||= 1
    params[:rows] ||= SETTINGS[:admin_grid_rows]

    grid = includes(:variants)#paginate({:page => params[:page]})
    grid = grid.where(['products.deleted_at IS NOT NULL AND products.deleted_at > ?', Time.now.to_s(:db)])  if active_state == false##  note nil != false
    grid = grid.where(['products.deleted_at IS NULL     OR  products.deleted_at < ?', Time.now.to_s(:db)])  if active_state == true
    grid = grid.where("products.name LIKE ?",                 "#{params[:name]}%")                  if params[:name].present?
    grid = grid.where("products.product_type_id = ?",      params[:product_type_id])       if params[:product_type_id].present?
    grid = grid.where("products.shipping_category_id = ?", params[:shipping_category_id])  if params[:shipping_category_id].present?
    grid = grid.where("products.available_at > ?",         params[:available_at_gt])       if params[:available_at_gt].present?
    grid = grid.where("products.available_at < ?",         params[:available_at_lt])       if params[:available_at_lt].present?
    grid
  end

  private
    def create_content
      self.description = BlueCloth.new(self.description_markup).to_html unless self.description_markup.blank?
    end

    # if the permalink is not filled in set it equal to the name
    def sanitize_data
      self.permalink = name if permalink.blank? && name
      self.permalink = permalink.squeeze(" ").strip.gsub(' ', '-') if permalink
      if meta_keywords.blank? && description
        self.meta_keywords =  [name[0..55],
                              description.
                              gsub(/\d/, "").                 # remove non-alpha numeric
                              squeeze(" ").                   # remove extra whitespace
                              gsub(/<\/?[^>]*>/, "").         # remove hyper text
                              split(' ').                     # split into an array
                              map{|w| w.length > 2 ? w : ''}. # remove words less than 2 characters
                              join(' ').strip[0..198]         # join and limit to 198 characters
                              ].join(': ')
      end
      self.meta_description = [name[0..55], description.gsub(/<\/?[^>]*>/, "").squeeze(" ").strip[0..198]].join(': ') if name.present? && description.present? && meta_description.blank?
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

      def self.standard_search(args, params)
          Product.search(:include => [:properties, :images]) do
            keywords(args)
            any_of do
              with(:deleted_at).greater_than(Time.zone.now)
              with(:deleted_at, nil)
            end
            paginate :page => params[:page].to_i, :per_page => params[:rows].to_i#params[:page], :per_page => params[:rows]
          end
      end
    end
=end
