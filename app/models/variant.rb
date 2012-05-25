# == Schema Information
#
# Table name: variants
#
#  id           :integer(4)      not null, primary key
#  product_id   :integer(4)      not null
#  sku          :string(255)     not null
#  name         :string(255)
#  price        :decimal(8, 2)   default(0.0), not null
#  cost         :decimal(8, 2)   default(0.0), not null
#  deleted_at   :datetime
#  master       :boolean(1)      default(FALSE), not null
#  created_at   :datetime
#  updated_at   :datetime
#  brand_id     :integer(4)
#  inventory_id :integer(4)
#

class Variant < ActiveRecord::Base


  has_many :variant_suppliers
  has_many :suppliers,         :through => :variant_suppliers

  has_many :variant_properties
  has_many :properties,          :through => :variant_properties

  has_many   :purchase_order_variants
  has_many   :purchase_orders, :through => :purchase_order_variants

  belongs_to :product
  belongs_to :brand
  belongs_to :inventory

  before_validation :create_inventory, :on => :create

  #validates :name,        :presence => true

  validates :inventory_id, :presence => true
  validates :price,       :presence => true
  validates :product_id,  :presence => true
  validates :sku,         :presence => true,       :length => { :maximum => 255 }

  accepts_nested_attributes_for :variant_properties#, :inventory

  delegate  :count_on_hand,
            :count_pending_to_customer,
            :count_pending_from_supplier,
            :count_on_hand=,
            :count_pending_to_customer=,
            :count_pending_from_supplier=, :to => :inventory, :allow_nil => false

  ADMIN_OUT_OF_STOCK_QTY  = 0
  OUT_OF_STOCK_QTY        = 2
  LOW_STOCK_QTY           = 6

  # returns quantity available to purchase
  #
  # @param [none]
  # @return [Boolean]
  def quantity_purchaseable(admin_purchase = false)
    admin_purchase ? (quantity_available - ADMIN_OUT_OF_STOCK_QTY) : (quantity_available - OUT_OF_STOCK_QTY)
  end

  # returns quantity available in stock
  #
  # @param [none]
  # @return [Boolean]
  def quantity_available
    (count_on_hand - count_pending_to_customer)
  end

  def active?
    deleted_at.nil? || deleted_at > Time.zone.now
  end

  # This is a form helper to inactivate a variant
  def inactivate=(val)
    self.deleted_at = Time.zone.now if !deleted_at && (val && (val == '1' || val.to_s == 'true'))
  end

  def inactivate
    deleted_at ? true : false
  end

  # returns true if the stock level is above or == the out of stock level
  #
  # @param [none]
  # @return [Boolean]
  def sold_out?
    (quantity_available) <= OUT_OF_STOCK_QTY
  end

  # returns true if the stock level is above or == the low stock level
  #
  # @param [none]
  # @return [Boolean]
  def low_stock?
    (quantity_available) <= LOW_STOCK_QTY
  end

  # returns "(Sold Out)" or "(Low Stock)" or "" depending on if the variant is out of stock / low stock or has enough stock.
  #
  # @param [Optional String]
  # @param [Optional String]
  # @return [String]
  def display_stock_status(start = '(', finish = ')')
    return "#{start}Sold Out#{finish}"  if sold_out?
    return "#{start}Low Stock#{finish}" if low_stock?
    ''
  end

  # price times the tax %
  #
  # @param [TaxRate]
  # @return [Decimal]
  def total_price(tax_rate)
    ((1 + tax_percentage(tax_rate)) * price)
  end

  # get the percent tax rate for the tax rate
  #
  # @param [TaxRate]
  # @return [Decimal] tax rate percentage
  def tax_percentage(tax_rate)
    tax_rate ? tax_rate.tax_percentage : 0.0
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
    brand_id ? brand.name : product.brand_name
  end

  # The variant has many properties.  but only one is the primary property
  #  this will return the primary property.  (good for primary info)
  #
  # @param [none]
  # @return [VariantProperty]
  def primary_property
    pp = self.variant_properties.where({ :variant_properties => {:primary => true}}).first
    pp ? pp : self.variant_properties.first
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
    ### don't lock if we have plenty of stock.
    if low_stock?
      inventory.lock!
        self.inventory.count_on_hand = inventory.count_on_hand + num.to_i
      inventory.save!
    else
      sql = "UPDATE inventories SET count_on_hand = (#{num} + count_on_hand) WHERE id = #{self.inventory.id}"
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  # with SQL math subtract to count_on_hand attribute
  #
  # @param [Integer] number of variants to subtract
  # @return [none]
  def subtract_count_on_hand(num)
    add_count_on_hand((num.to_i * -1))
  end

  # with SQL math add to count_pending_to_customer attribute
  #
  # @param [Integer] number of variants to add
  # @return [none]
  def add_pending_to_customer(num = 1)
    ### don't lock if we have plenty of stock.
    if low_stock?
      # If the stock is low lock the inventory.  This ensures
      inventory.lock!
      self.inventory.count_pending_to_customer = inventory.count_pending_to_customer.to_i + num.to_i
      inventory.save!
    else
      sql = "UPDATE inventories SET count_pending_to_customer = (#{num} + count_pending_to_customer) WHERE id = #{self.inventory.id}"
      ActiveRecord::Base.connection.execute(sql)
    end
  end

  # with SQL math subtract to count_pending_to_customer attribute
  #
  # @param [Integer] number of variants to subtract
  # @return [none]
  def subtract_pending_to_customer(num)
    add_pending_to_customer((num.to_i * -1))
  end

  # in the admin form qty_to_add to the count on hand
  #
  # @param [Integer] number of variants to add or subtract (negative sign is subtract)
  # @return [none]
  def qty_to_add=(num)
    ###  TODO this method needs a history of who did what
    inventory.lock!
    self.inventory.count_on_hand = inventory.count_on_hand.to_i + num.to_i
    inventory.save!
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
    grid = where({:variants => { :product_id => product.id} })
    grid = grid.includes(:product)
    grid = grid.where({:products => {:name => params[:product_name]}})  if params[:product_name].present?
    grid = grid.where(['sku LIKE ? ', "#{params[:sku]}%"])  if params[:sku].present?
    grid
  end

  private

    def create_inventory
      self.inventory = Inventory.create({:count_on_hand => 0, :count_pending_to_customer => 0, :count_pending_from_supplier => 0}) unless inventory
    end
end
