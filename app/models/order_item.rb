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

  def set_beginning_values
    @beginning_tax_rate_id      = self.tax_rate_id      rescue @beginning_tax_rate_id = nil # this stores the initial value of the tax_rate
    @beginning_shipping_rate_id = self.shipping_rate_id rescue @beginning_shipping_rate_id = nil # this stores the initial value of the tax_rate
    @beginning_total            = self.total            rescue @beginning_total = nil # this stores the initial value of the total
  end

 state_machine :initial => 'unpaid' do


   #after_transition :to => 'complete', :do => [:update_inventory]
 end

  def shipped?
    shipment_id?
  end

  def shipping_method
    shipping_rate.shipping_method
  end

  def shipping_method_id
    shipping_rate.shipping_method_id
  end

  def self.order_items_in_cart(order_id)
    find(:all, :joins => {:variant => :product },
               :conditions => { :order_items => { :order_id => order_id}},
               :select => "order_items.*, count(*) as quantity,
                                          products.shipping_category_id as shipping_category_id,
                                          SUM(order_items.price) as sum_price,
                                          SUM(order_items.total) as sum_total",
               :group => "order_items.variant_id")
  end

  def calculate_order
    if self.ready_to_calculate? &&
        (shipping_rate_id != @beginning_shipping_rate_id || tax_rate_id != @beginning_tax_rate_id)
      set_beginning_values
      order.calculate_totals
    end
  end

  def set_order_calculated_at_to_nil
    order.update_attribute(:calculated_at, nil)
  end

  def ready_to_calculate?
    shipping_rate_id && tax_rate_id
  end
  # this is the price after coupons and anything before calculating the price + tax
  def adjusted_price
    ## coupon credit is calculated at the order level but because taxes we need to apply it now
    # => this calculation will be complete in the version of Hadean
    coupon_credit = 0.0

    self.price - coupon_credit
  end

  def calculate_total(coupon = nil)
    # shipping charges are calculated in order.rb

    self.total = (adjusted_price + tax_charge).round_at(2)
  end

  def tax_charge
    tax_percentage = tax_rate.try(:percentage) ? tax_rate.try(:percentage) : 0.0
    adjusted_price * tax_percentage / 100.0
  end
end
