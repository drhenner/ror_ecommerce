class Variant < ActiveRecord::Base


  has_many :variant_suppliers
  has_many :suppliers,         :through => :variant_suppliers

  has_many :variant_properties
  has_many :properties,          :through => :variant_properties

  has_many   :purchase_order_variants
  has_many   :purchase_orders, :through => :purchase_order_variants

  belongs_to :product
  belongs_to :brand

  #validates :name,        :presence => true
  validates :price,       :presence => true
  validates :product_id,  :presence => true
  validates :sku,         :presence => true

  accepts_nested_attributes_for :variant_properties

  OUT_OF_STOCK_QTY = 2
  LOW_STOCK_QTY    = 6

  # returns true if the stock level is above or == the out of stock level
  #
  # @param [none]
  # @return [Boolean]
  def sold_out?
    (count_on_hand - count_pending_to_customer) <= OUT_OF_STOCK_QTY
  end

  # returns true if the stock level is above or == the low stock level
  #
  # @param [none]
  # @return [Boolean]
  def low_stock?
    (count_on_hand - count_pending_to_customer) <= LOW_STOCK_QTY
  end

  # returns "(Sold Out)" or "(Low Stock)" or "" depending on if the variant is out of stock / low stock or has enough stock.
  #
  # @param [Optional String]
  # @param [Optional String]
  # @return [String]
  def display_stock_status(start = '(', finish = ')')
    return "#{start}Sold Out#{finish}"  if self.sold_out?
    return "#{start}Low Stock#{finish}" if self.low_stock?
    ''
  end

  # price times the tax %
  #
  # @param [TaxRate]
  # @return [Decimal]
  def total_price(tax_rate)
    ((1 + tax_percentage(tax_rate)) * self.price)
  end

  # get the percent tax rate for the tax rate
  #
  # @param [TaxRate]
  # @return [Decimal] tax rate percentage
  def tax_percentage(tax_rate)
    tax_rate ? tax_rate.percentage : 0.0
  end

  # gives you the tax rate for the give state_id and the time.
  #  Tax rates can change from year to year so Time is a factor
  #
  # @param [Integer] state.id
  # @param [Optional Time] Time now if no value is passed in
  # @return [TaxRate] TaxRate for the state at a given time
  def product_tax_rate(state_id, tax_time = Time.now)
    product.tax_rate(state_id, tax_time)
  end

  # convienence method to get the shipping_category_id of the product
  #
  # @param [none]
  # @return [Integer] shipping_category_id
  def shipping_category_id
    product.shipping_category_id
  end

  # returns an array of the display name and description of all the variant properties
  #  ex: obj.sub_name => ['color: green', 'size: 9.0']
  #
  # @param [Optional String]
  # @return [Array]
  def property_details(separator = ': ')
    variant_properties.collect {|vp| [vp.property.display_name ,vp.description].join(separator) }
  end

  # returns a string the display name and description of all the variant properties
  #  ex: obj.sub_name => 'color: green <br/> size: 9.0']
  #
  # @param [Optional String] separator (default == <br/>)
  # @return [String]
  def display_property_details(separator = '<br/>')
    property_details.join(separator)
  end

  # returns the product name
  #  ex: obj.product_name => Nike
  #
  # @param [none]
  # @return [String]
  def product_name
    name? ? name : product.name + sub_name
  end

  # returns the primary_property's description or a blank string
  #  ex: obj.sub_name => 'great shoes, blah blah blah'
  #
  # @param [none]
  # @return [String]
  def sub_name
    primary_property ? "(#{primary_property.description})" : ''
  end

  # returns the brand's name or a blank string
  #  ex: obj.brand_name => 'Nike'
  #
  # @param [none]
  # @return [String]
  def brand_name
    brand_id ? brand.name : ''
  end

  # The variant has many properties.  but only one is the primary property
  #  this will return the primary property.  (good for primary info)
  #
  # @param [none]
  # @return [VariantProperty]
  def primary_property
    pp = self.variant_properties.where({ :variant_properties => {:primary => true}}).find(:first)
    pp ? pp : self.variant_properties.find(:first)
  end

  # returns the product name with sku
  #  ex: obj.name_with_sku => Nike: 1234-12345-1234
  #
  # @param [none]
  # @return [String]
  def name_with_sku
    [product_name, sku].compact.join(': ')
  end

  # returns true or false based on if the count_available is above 0
  #
  # @param [Integer] number of variants to subtract
  # @return [Boolean]
  def is_available?
    count_available > 0
  end

  # returns number available to purchase
  #
  # @param [Boolean] reload the object from the DB
  # @return [Integer] number available to purchase
  def count_available(reload_variant = true)
    self.reload if reload_variant
    count_on_hand - count_pending_to_customer
  end

  # with SQL math add to count_on_hand attribute
  #
  # @param [Integer] number of variants to add
  # @return [none]
  def add_count_on_hand(num)
      sql = "UPDATE variants SET count_on_hand = (#{num} + count_on_hand) WHERE id = #{self.id}"
      ActiveRecord::Base.connection.execute(sql)
  end

  # with SQL math subtract to count_on_hand attribute
  #
  # @param [Integer] number of variants to subtract
  # @return [none]
  def subtract_count_on_hand(num)
    add_count_on_hand((num * -1))
  end

  # with SQL math add to count_pending_to_customer attribute
  #
  # @param [Integer] number of variants to add
  # @return [none]
  def add_pending_to_customer(num = 1)
      sql = "UPDATE variants SET count_pending_to_customer = (#{num} + count_pending_to_customer) WHERE id = #{self.id}"
      ActiveRecord::Base.connection.execute(sql)
  end

  # with SQL math subtract to count_pending_to_customer attribute
  #
  # @param [Integer] number of variants to subtract
  # @return [none]
  def subtract_pending_to_customer(num)
    add_pending_to_customer((num * -1))
  end

  # in the admin form qty_to_add to the count on hand
  #
  # @param [Integer] number of variants to add or subtract (negative sign is subtract)
  # @return [none]
  def qty_to_add=(num)
    ###  TODO this method needs a history of who did what
    self.count_on_hand = self.count_on_hand + num.to_i
  end

  # method used by forms to set the initial qty_to_add for variants
  #
  # @param [none]
  # @return [Integer] 0
  def qty_to_add
    0
  end

  # paginated results from the admin Variant grid
  #
  # @param [Variant]
  # @param [Optional params]
  # @return [ Array[Variant] ]
  def self.admin_grid(product, params = {})

    params[:page] ||= 1
    params[:rows] ||= SETTINGS[:admin_grid_rows]

    grid = Variant.where({:variants => { :product_id => product.id} })
    grid = grid.includes(:product)
    grid = grid.where({:products => {:name => params[:name]}})  if params[:name].present?
    grid = grid.order("#{params[:sidx]} #{params[:sord]}")
    grid.paginate({:page => params[:page],:per_page => params[:rows]})
  end

end
