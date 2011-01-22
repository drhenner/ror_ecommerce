class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :shipping_rate
  belongs_to :variant
  belongs_to :tax_rate
  belongs_to :shipment

  has_many   :return_items

  #after_save :calculate_order
  after_find :set_beginning_values
  after_destroy :set_order_calculated_at_to_nil

  validates :variant_id,  :presence => true
  validates :order_id,    :presence => true

  def set_beginning_values
    @beginning_tax_rate_id      = self.tax_rate_id      rescue @beginning_tax_rate_id = nil # this stores the initial value of the tax_rate
    @beginning_shipping_rate_id = self.shipping_rate_id rescue @beginning_shipping_rate_id = nil # this stores the initial value of the tax_rate
    @beginning_total            = self.total            rescue @beginning_total = nil # this stores the initial value of the total
  end

 state_machine :initial => 'unpaid' do


   #after_transition :to => 'complete', :do => [:update_inventory]
 end

 # if the order item has been shipped it will return true
 #
 # @param [none]
 # @return [Boolean]
  def shipped?
    shipment_id?
  end

  # shipping method for the order item
  #
  # @param [none]
  # @return [ShippingMethod]
  def shipping_method
    shipping_rate.shipping_method
  end

  # shipping method id for the order item (use to reduce SQL calls)
  #   refer to ShippingMethod ID constants to determine what shipping method is called
  #
  # @param [none]
  # @return [Integer] ShippingMethod id
  def shipping_method_id
    shipping_rate.shipping_method_id
  end

  # called in checkout process. will give you the 'quantity', 'sum of all the prices' and 'sum of all the totals'
  #  it is better to do the math in SQL than ruby
  #
  # @param [Integer]  order.id
  # @return [OrderItem] Object has addional attributes of [sum_price, sum_total, shipping_category_id, and quantity]
  def self.order_items_in_cart(order_id)
    find(:all, :joins => {:variant => :product },
               :conditions => { :order_items => { :order_id => order_id}},
               :select => "order_items.*, count(*) as quantity,
                                          products.shipping_category_id as shipping_category_id,
                                          SUM(order_items.price) as sum_price,
                                          SUM(order_items.total) as sum_total",
               :group => "order_items.variant_id")
  end

  # forces the order to be re-calculated.  If the order item has changed then the order totals need to be adjusted
  #
  # @param [none]
  # @return [none]
  def calculate_order
    if self.ready_to_calculate? &&
        (shipping_rate_id != @beginning_shipping_rate_id || tax_rate_id != @beginning_tax_rate_id)
      set_beginning_values
      order.calculate_totals
    end
  end

  # if something changes to the order item and you dont want to recalculate
  #   (maybe because you are chnging several more things) then
  #    this method will mark the calculated at to be nil and thus tell the order that
  #    it needs to calculate the total again
  #
  # @param [none]
  # @return [none]
  def set_order_calculated_at_to_nil
    order.update_attribute(:calculated_at, nil)
  end

  # determines if the order item has all the attributes set and thus you can now determine the final total
  #
  # @param [none]
  # @return [Boolean]
  def ready_to_calculate?
    shipping_rate_id && tax_rate_id
  end

  # this is the price after coupons and anything before calculating the price + tax
  #  in the future coupons and discounts could change this value
  #
  # @param [none]
  # @return [Float] this is the price that the tax will be applied to.
  def adjusted_price
    ## coupon credit is calculated at the order level but because taxes we need to apply it now
    # => this calculation will be complete in the version of Hadean
    coupon_credit = 0.0

    self.price - coupon_credit
  end

  # this is the price after coupons and taxes
  #   * this return total if has not been calculated, otherwise calculates the total.
  #
  # @param [none]
  # @return [Float] this is the total of the item after taxes and coupons...
  def item_total(coupon = nil)
    # shipping charges are calculated in order.rb

    self.total ||= calculate_total(coupon = nil)
  end

  # this is the price after coupons and taxes
  #   * this method does not save it just sets the value of total.
  #   * Thus allowing you to save the whole order with one opperation
  #
  # @param [none]
  # @return [Float] this is the total of the item after taxes and coupons...
  def calculate_total(coupon = nil)
    # shipping charges are calculated in order.rb

    self.total = (adjusted_price + tax_charge).round_at(2)
  end

  # the tax charge on an item
  #
  # @param [none]
  # @return [Float] tax charge on the item.
  def tax_charge
    tax_percentage = tax_rate.try(:percentage) ? tax_rate.try(:percentage) : 0.0
    adjusted_price * tax_percentage / 100.0
  end
end
