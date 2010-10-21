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

  def tax_rate(state_id, time = Time.zone.now)
    self.tax_status.tax_rates.where(["state_id = ? AND 
                           start_date <= ? AND
                           (end_date > ? OR end_date IS NULL) AND
                           active = ?", state_id, 
                                        time.to_date.to_s(:db), 
                                        time.to_date.to_s(:db), 
                                        true]).order('start_date DESC').first
  end

  def price
    master_variant ? master_variant.price : last_master_variant.price
  end
  
  def set_keywords=(value)
    self.product_keywords = value ? value.split(',').map{|w| w.strip} : []
  end
  
  def set_keywords
    self.product_keywords ? self.product_keywords.join(', ') : ''
  end
  
  def primary_image_url(image_size = :small)
    images.first ? images.first.photo.url(image_size) : nil
  end

  def display_price_range(j = ' to ')
    price_range.join(j)
  end
  
  def price_range
    range = variants.inject([variants.first.price, variants.first.price]) do |a, variant|
      a[0] = variant.price if variant.price < a[0]
      a[1] = variant.price if variant.price > a[1]
      a
    end
  end
  
  def last_master_variant
    inactive_master_variants.last
  end
  
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
  
  def self.featured
    product = Product.where("products.featured = ? ", true).includes(:images).first
    product ? product : Product.includes(:images).where(['products.deleted_at IS NULL']).first
  end
  
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
    grid = grid.limit(params[:rows])
    grid = grid.order("#{params[:sidx]} #{params[:sord]}").paginate(:page => params[:page], :per_page => params[:rows])
  end
end
