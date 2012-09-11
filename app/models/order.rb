# == Schema Information
#
# Table name: orders
#
#  id              :integer(4)      not null, primary key
#  number          :string(255)
#  ip_address      :string(255)
#  email           :string(255)
#  state           :string(255)
#  user_id         :integer(4)
#  bill_address_id :integer(4)
#  ship_address_id :integer(4)
#  coupon_id       :integer(4)
#  active          :boolean(1)      default(TRUE), not null
#  shipped         :boolean(1)      default(FALSE), not null
#  shipments_count :integer(4)      default(0)
#  calculated_at   :datetime
#  completed_at    :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  credited_amount :decimal(8, 2)   default(0.0)
#

class Order < ActiveRecord::Base
  has_friendly_id :number, :use_slug => false

  has_many   :order_items, :dependent => :destroy
  has_many   :shipments
  has_many   :invoices
  has_many   :completed_invoices,  :class_name => 'Invoice', :conditions => ['state = ? OR state = ?', 'authorized', 'paid']
  has_many   :authorized_invoices, :class_name => 'Invoice', :conditions => ['state = ?', 'authorized']
  has_many   :paid_invoices      , :class_name => 'Invoice', :conditions => ['state = ?', 'paid']
  has_many   :return_authorizations
  has_many   :comments, :as => :commentable

  belongs_to :user
  belongs_to :coupon
  belongs_to   :ship_address, :class_name => 'Address'
  belongs_to   :bill_address, :class_name => 'Address'

  before_validation :set_email, :set_number
  after_create      :save_order_number
  before_save       :update_tax_rates


  # after_find :set_beginning_values

  attr_accessor :total, :sub_total, :deal_amount

  #validates :number,     :presence => true
  validates :user_id,     :presence => true
  validates :email,       :presence => true,
                          :format   => { :with => CustomValidators::Emails.email_validator }

  NUMBER_SEED     = 1001001001000
  CHARACTERS_SEED = 21

  state_machine :initial => 'in_progress' do
    after_transition :to => 'paid', :do => [:mark_items_paid]

    event :complete do
      transition :to => 'complete', :from => 'in_progress'
    end

    event :pay do
      transition :to => 'paid', :from => ['in_progress', 'complete']
    end
  end

  #  This method is used when the session in admin orders is ready to authorize the credit card
  #   The cart has the following format
  #
  #  session[:admin_cart] = {
  #    :user             => nil,
  #    :shipping_address => nil,
  #    :billing_address  => nil,
  #    :coupon           => nil,
  #    :shipping_method  => nil,
  #    :order_items => {}# the key is variant_id , a hash of {variant, shipping_rate, quantity, tax_rate, total, shipping_category_id}
  #  }

  def mark_items_paid
    order_items.map(&:pay!)
  end

  # user name on the order
  #
  # @param [none]
  # @return [String] user name on the order
  def name
    self.user.name
  end

  # formated date of the complete_at datetime on the order
  #
  # @param [none]
  # @return [String] formated date or 'Not Finished.' if the order is not completed
  def display_completed_at(format = :us_date)
    completed_at ? I18n.localize(completed_at, :format => format) : 'Not Finished.'
  end

  # how much you initially charged the customer
  #
  # @param [none]
  # @return [String] amount in dollars as decimal or a blank string
  def first_invoice_amount
    return '' if completed_invoices.empty?
    completed_invoices.first.amount
  end

  # cancel the order and payment
  # => sets the order inactive and cancels the authorized payments
  #
  # @param [Invoice]
  # @return [none]
  def cancel_unshipped_order(invoice)
    transaction do
      self.update_attributes(:active => false)
      invoice.cancel_authorized_payment
    end
  end

  # status of the invoice
  #
  # @param [none]
  # @return [String] state of the latest invoice or 'not processed' if there aren't any invoices
  def status
    return 'not processed' if invoices.empty?
    invoices.last.state
  end

  def self.find_myaccount_details
    includes([:completed_invoices, :invoices])
  end

  # The admin cart is stored in memcached.  At checkout the order is stored in the DB.  This method will store the checkout.
  #
  # @param [Hash] memcached hash of the cart
  # @param [Hash] arguments with ip_address
  # @return [Order] order created
  def self.new_admin_cart(admin_cart, args = {})
    transaction do
      admin_order = Order.new(  :ship_address     => admin_cart[:shipping_address],
                                :bill_address     => admin_cart[:billing_address],
                                #:coupon           => admin_cart[:coupon],
                                :email            => admin_cart[:user].email,
                                :user             => admin_cart[:user],
                                :ip_address       => args[:ip_address]
                            )
      admin_order.save
      admin_cart[:order_items].each_pair do |variant_id, hash|
          hash[:quantity].times do
              item = OrderItem.new( :variant        => hash[:variant],
                                    :tax_rate       => hash[:tax_rate],
                                    :price          => hash[:variant].price,
                                    :total          => hash[:total],
                                    :shipping_rate  => hash[:shipping_rate]
                                )
              admin_order.order_items.push(item)
          end
      end
      admin_order.save
      admin_order
    end
  end

  def add_cart_item( item, state_id = nil)
    self.save! if self.new_record?
    tax_rate_id = state_id ? item.variant.product.tax_rate(state_id) : nil
    item.quantity.times do
      oi =  OrderItem.create(
          :order        => self,
          :variant_id   => item.variant.id,
          :price        => item.variant.price,
          :tax_rate_id  => tax_rate_id)
      self.order_items.push(oi)
    end
  end

  # captures the payment of the invoice by the payment processor
  #
  # @param [Invoice]
  # @return [Payment] payment object
  def capture_invoice(invoice)
    payment = invoice.capture_payment({})
    self.pay! if payment.success
    payment
  end


  ## This method creates the invoice and payment method.  If the payment is not authorized the whole transaction is roled back
  def create_invoice(credit_card, charge_amount, args, credited_amount = 0.0)
    transaction do
      create_invoice_transaction(credit_card, charge_amount, args, credited_amount)
    end
  end

  # call after the order is completed (authorized the payment)
  # => sets the order.state to completed, sets completed_at to time.now and updates the inventory
  #
  # @param [none]
  # @return [Payment] payment object
  def order_complete!
    self.state = 'complete'
    self.completed_at = Time.zone.now
    update_inventory
  end

  # This method will go to every order_item and calculate the total for that item.
  #
  # if calculated at is set this order does not need to be calculated unless
  # any single item in the order has been updated since the order was calculated
  #
  # Also if any item is not ready to calculate then dont calculate
  #
  # @param [none] the param is not used right now
  # @return [none]
  def calculate_totals
    # if calculated at is nil then this order hasn't been calculated yet
    # also if any single item in the order has been updated, the order needs to be re-calculated
    if calculated_at.nil? || (order_items.any? {|item| (item.updated_at > self.calculated_at) })
      # if any item is not ready to calculate then dont calculate
      unless order_items.any? {|item| !item.ready_to_calculate? }
        total = 0.0
        tax_time = completed_at? ? completed_at : Time.zone.now
        order_items.each do |item|
          if (calculated_at.nil? || item.updated_at > self.calculated_at)
            item.tax_rate = item.variant.product.tax_rate(self.ship_address.state_id, tax_time)## This needs to change to completed_at
            item.calculate_total
            item.save
          end
          total = total + item.total
        end
        sub_total = total
        self.total = total + shipping_charges
        self.calculated_at = Time.now
        save
      end
    end
  end

  # This returns a hash where product_type_id is the key and an Array of prices are the values.
  #   This method is specifically used for Deal.rb
  #
  # @return [Hash] This returns a hash of { product_type_id => [price, price]}
  def number_of_a_given_product_type
     return_hash = order_items.inject({}) do |hash, oi|
       oi.product_type_ids.each do |product_type_id|
         hash[product_type_id] ||= []
         hash[product_type_id] << oi.price#.to_s
       end
       hash
     end#.sort_by{|v| v.values.first.size }.reverse
     return_hash.delete_if{|k,v| k == 1}
  end
  # looks at all the order items and determines if the order has all the required elements to complete a checkout
  #
  # @param [none]
  # @return [Boolean]
  def ready_to_checkout?
    order_items.all? {|item| item.ready_to_calculate? }
  end

  # calculates the total price of the order
  # this method will set sub_total and total for the order even if the order is not ready for final checkout
  #
  # @param [none] the param is not used right now
  # @return [none]  Sets sub_total and total for the object
  def find_total(force = false)
    calculate_totals if self.calculated_at.nil? || order_items.any? {|item| (item.updated_at > self.calculated_at) }
    self.deal_amount = Deal.best_qualifing_deal(self)
    self.find_sub_total
    self.total = (self.total + shipping_charges - deal_amount - coupon_amount ).round_at( 2 )
  end

  def find_sub_total
    self.total = 0.0
    order_items.each do |item|
      self.total = self.total + item.item_total
    end
    self.sub_total = self.total
  end

  # amount the coupon reduces the value of the order
  #
  # @param [none]
  # @return [Float] amount the coupon reduces the value of the order
  def coupon_amount
    coupon_id ? coupon.value(item_prices, self) : 0.0
  end

  # called when creating the invoice.  This does not change the store_credit amount
  #
  # @param [none]
  # @return [Float] amount that the order is charged after store credit is applyed
  def credited_total
    (find_total - amount_to_credit).round_at( 2 )
  end

  # amount to credit based off the user store credit
  #
  # @param [none]
  # @return [Float] amount to remove from store credit
  def amount_to_credit
    [find_total, user.store_credit.amount].min
  end

  def remove_user_store_credits
    user.store_credit.remove_credit(amount_to_credit) if amount_to_credit > 0.0
  end

  # calculates the total shipping charges for all the items in the cart
  #
  # @param [none]
  # @return [Decimal] amount of the shipping charges
  def shipping_charges(items = nil)
    return @order_shipping_charges if defined?(@order_shipping_charges)
    @order_shipping_charges = shipping_rates(items).inject(0.0) {|sum, shipping_rate|  sum + shipping_rate.rate  }
  end

  def display_shipping_charges
    items = OrderItem.order_items_in_cart(self.id)
    return 'TBD' if items.any?{|i| i.shipping_rate_id.nil? }
    shipping_charges(items)
  end

  # all the shipping rate to apply to the order
  #
  # @param [none]
  # @return [Array] array of shipping rates that will be charged, it will return the same
  #                 shipping rate more than once if it can be charged more than once
  def shipping_rates(items = nil)
    items ||= OrderItem.order_items_in_cart(self.id)
    rates = items.inject([]) do |rates, item|
      rates << item.shipping_rate if item.shipping_rate.individual? || !rates.include?(item.shipping_rate)
      rates
    end
  end

  # all the tax charges to apply to the order
  #
  # @param [none]
  # @return [Array] array of tax charges that will be charged
  def tax_charges
    charges = order_items.inject([]) do |charges, item|
      charges << item.tax_charge
      charges
    end
  end

  # sum of all the tax charges to apply to the order
  #
  # @param [none]
  # @return [Decimal]
  def total_tax_charges
    tax_charges.sum
  end

  # add the variant to the order items in the order, normally called at order creation
  #
  # @param [Variant] variant to add
  # @param [Integer] quantity to add to the order
  # @param [Optional Integer] state_id (for taxes) to assign to the order_item
  # @return [none]
  def add_items(variant, quantity, state_id = nil)
    self.save! if self.new_record?
    tax_rate_id = state_id ? variant.product.tax_rate(state_id) : nil
    quantity.times do
      self.order_items.push(OrderItem.create(:order => self,:variant_id => variant.id, :price => variant.price, :tax_rate_id => tax_rate_id))
    end
  end

  # remove the variant from the order items in the order
  #   THIS METHOD IS COMPLEX FOR A REASON!!!
  #   USING slice! ALLOWS THE ORDER_ITEMS TO BE DESTROYED AND UNASSOCIATED FROM THE ORDER OBJECT
  #
  # @param [Variant] variant to add
  # @param [Integer] final quantity that should be in the order
  # @return [none]
  def remove_items(variant, final_quantity)

    current_qty = 0
    items_to_remove = []
    self.order_items.each_with_index do |order_item, i|
      if order_item.variant_id == variant.id
        current_qty = current_qty + 1
        items_to_remove << i  if (current_qty - final_quantity) > 0
      end
    end
    items_to_remove.reverse.each do |i|
      self.order_items.slice!(i ,1).first.destroy # remove from order.order_items object and destroy from DB
    end
  end

  ## determines the order id from the order.number
  #
  # @param [String]  represents the order.number
  # @return [Integer] id of the order to find
  def self.id_from_number(num)
    num.to_i(CHARACTERS_SEED) - NUMBER_SEED
  end

  ## finds the Order from the orders number.  Is more optimal than the normal rails find by id
  #      because if calculates the order's id which is indexed
  #
  # @param [String]  represents the order.number
  # @return [Order]
  def self.find_by_number(num)
    find(id_from_number(num))##  now we can search by id which should be much faster
  end

  ## This method is called when the order transitions to paid
  #   it will add the number of variants pending to be sent to the customer
  #
  # @param none
  # @return [none]
  def update_inventory
    self.order_items.each { |item| item.variant.add_pending_to_customer }
  end

  # variant ids in the order.
  #
  # @param [none]
  # @return [Integer] all the variant_id's in the order
  def variant_ids
    order_items.collect{|oi| oi.variant_id }
  end


  # if the order has a shipment this is true... else false
  #
  # @param [none]
  # @return [Boolean]
  def has_shipment?
    shipments_count > 0
  end

  def self.create_subscription_order(user)
    order = Order.new(
              :user   => user,
              :email  => user.email,
              :bill_address => user.billing_address,
              :ship_address => user.shipping_address
                      )
    oi = OrderItem.new( :total            => user.account.monthly_charge,
                        :price            => user.account.monthly_charge,
                        :variant_id       => Variant::MONTHLY_BILLING_ID,
                        :shipping_rate_id => ShippingRate::MONTHLY_BILLING_RATE_ID
                      )
    order.push(oi)
    order.save
    order
  end

  # paginated results from the admin orders that are completed grid
  #
  # @param [Optional params]
  # @return [ Array[Order] ]
  def self.find_finished_order_grid(params = {})

    params[:page] ||= 1
    params[:rows] ||= 25

    grid = Order
    grid = grid.includes([:user])
    grid = grid.where({:active => true })                     unless  params[:show_all].present? &&
                                                                      params[:show_all] == 'true'
    grid = grid.where("orders.shipment_counter = ?", 0)             if params[:shipped].present? && params[:shipped] == 'true'
    grid = grid.where("orders.shipment_counter > ?", 0)            if params[:shipped].present? && params[:shipped] == 'false'
    grid = grid.where("orders.completed_at IS NOT NULL")
    grid = grid.where("orders.number LIKE ?", "#{params[:number]}%")  if params[:number].present?
    grid = grid.where("orders.email LIKE ?", "#{params[:email]}%")    if params[:email].present?
    grid = grid.order("#{params[:sidx]} #{params[:sord]}").paginate(:page => params[:page].to_i, :per_page => params[:rows].to_i)

  end

  # paginated results from the admin order fulfillment grid
  #
  # @param [Optional params]
  # @return [ Array[Order] ]
  def self.fulfillment_grid(params = {})
    grid = self
    grid = grid.includes([:user])
    grid = grid.where({:active => true })                     unless  params[:show_all].present? &&
                                                                      params[:show_all] == 'true'
    grid = grid.where({ :orders => {:shipped => false }} )
    grid = grid.where("orders.completed_at IS NOT NULL")
    grid = grid.where("orders.number LIKE ?", "#{params[:number]}%")  if params[:number].present?
    grid = grid.where("orders.shipped = ?", true)               if (params[:shipped].present? && params[:shipped] == 'true')
    grid = grid.where("orders.email LIKE ?", "#{params[:email]}%")    if params[:email].present?
    grid
  end

  private

  # prices to charge of all items before taxes and coupons and shipping
  #
  # @param none
  # @return [Array] Array of prices to charge of all items before
  def item_prices
    order_items.collect{|item| item.adjusted_price }
  end

  # Called before validation.  sets the email address of the user to the order's email address
  #
  # @param none
  # @return [none]
  def set_email
    self.email = user.email if user_id
  end

  # Called before validation.  sets the order number, if the id is nil the order number is bogus
  #
  # @param none
  # @return [none]
  def set_number
    return set_order_number if self.id
    self.number = (Time.now.to_i).to_s(CHARACTERS_SEED)## fake number for friendly_id validator
  end

  # sets the order number based off constants and the order id
  #
  # @param none
  # @return [none]
  def set_order_number
    self.number = (NUMBER_SEED + id).to_s(CHARACTERS_SEED)
  end


  # Called after_create.  sets the order number
  #
  # @param none
  # @return [none]
  def save_order_number
    set_order_number
    save
  end

  # Called before save.  If the ship address changes the tax rate for all the order items needs to change appropriately
  #
  # article.title  #=> "Title"
  # article.title = "New Title"
  # article.title_changed? #=> true
  # @param none
  # @return [none]
  def update_tax_rates
    if ship_address_id_changed?
      # set_beginning_values
      tax_time = completed_at? ? completed_at : Time.zone.now
      order_items.each do |item|
        rate = item.variant.product.tax_rate(self.ship_address.state_id, tax_time)
        if rate && item.tax_rate_id != rate.id
          item.tax_rate = rate
          item.save
        end
      end
    end
  end

  def create_invoice_transaction(credit_card, charge_amount, args, credited_amount = 0.0)
    invoice_statement = Invoice.generate(self.id, charge_amount, credited_amount)
    invoice_statement.save
    invoice_statement.authorize_payment(credit_card, args)#, options = {})
    invoices.push(invoice_statement)
    if invoice_statement.succeeded?
      self.order_complete! #complete!
      self.save
    else
      #role_back
      invoice_statement.errors.add(:base, 'Payment denied!!!')
      invoice_statement.save

    end
    invoice_statement
  end
end
