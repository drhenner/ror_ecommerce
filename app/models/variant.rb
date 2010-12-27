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
  def sold_out?
    (count_on_hand - count_pending_to_customer) <= OUT_OF_STOCK_QTY
  end

  def low_stock?
    (count_on_hand - count_pending_to_customer) <= LOW_STOCK_QTY
  end

  def display_stock_status(start = '(', finish = ')')
    return "#{start}Sold Out#{finish}"  if self.sold_out?
    return "#{start}Low Stock#{finish}" if self.low_stock?
    ''
  end

  def total_price(tax_rate)
    ((1 + tax_percentage(tax_rate)) * self.price)
  end

  def tax_percentage(tax_rate)
    tax_rate ? tax_rate.percentage : 0
  end

  def product_tax_rate(state_id, tax_time = Time.now)
    product.tax_rate(state_id, tax_time)
  end

  def shipping_category_id
    product.shipping_category_id
  end

  def display_property_details(separator = '<br/>')
    property_details.join(separator)
  end

  def property_details(separator = ': ')
    variant_properties.collect {|vp| [vp.property.display_name ,vp.description].join(separator) }
  end

  def product_name
    name? ? name : product.name + sub_name
  end

  def sub_name
    primary_property ? "(#{primary_property.description})" : ''
  end

  def primary_property
    pp = self.variant_properties.where({ :variant_properties => {:primary => true}}).find(:first)
    pp ? pp : self.variant_properties.find(:first)
  end

  def name_with_sku
    [product_name, sku].compact.join(': ')
  end

  def qty_to_add
    0
  end

  def is_available?
    count_available > 0
  end

  def count_available(reload_variant = true)
    self.reload if reload_variant
    count_on_hand - count_pending_to_customer
  end

  def add_count_on_hand(num)
      sql = "UPDATE variants SET count_on_hand = (#{num} + count_on_hand) WHERE id = #{self.id}"
      ActiveRecord::Base.connection.execute(sql)
  end

  def subtract_count_on_hand(num)
    add_count_on_hand((num * -1))
  end

  def add_pending_to_customer(num = 1)
      sql = "UPDATE variants SET count_pending_to_customer = (#{num} + count_pending_to_customer) WHERE id = #{self.id}"
      ActiveRecord::Base.connection.execute(sql)
  end

  def subtract_pending_to_customer(num)
    add_pending_to_customer((num * -1))
  end

  def qty_to_add=(num)
    ###  TODO this method needs a history of who did what
    self.count_on_hand = self.count_on_hand + num.to_i
  end

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
