# Coupons are straight forward.  Picture a coupon you have in a grocery store.
# The only big difference in the grocery store you can have 30 coupon for different items you buy.
# For ror-e you can only have one Coupon for an entire order.  This is pretty standard in the ecommerce world.

# The method that is most important:
#
# qualified?
#
# This method does 2 things:
#
# 1) it determines if the items in your cart cost enough to reach the minimum qualifing amount needed for the coupon to work.
# 2) it determines if the coupon is "eligible?"  (eligible? is a method)
#
#  The eligible? method changes functionality depending on what type of coupon is created.
#    => at the most basic level it determines if the date of the order is greater than starts_at and less than expires_at
#
#  For first_purchase_xxxxx  coupons eligible? also ensures the order that this is being applied
#   to is the first item you have ever purchased.
#
####################################################################################
###  NOTE!!!  NOTE!!!  NOTE!!!  NOTE!!!  NOTE!!!  NOTE!!!  NOTE!!!  NOTE!!!  NOTE!!!  NOTE!!!  NOTE!!!  NOTE!!!
###  eligible? uses (order.completed_at || Time.zone.now)
###  thus being accurate for returned items and items being purchased right now.
####################################################################################


# == Schema Information
#
# Table name: coupons
#
#  id            :integer(4)      not null, primary key
#  type          :string(255)     not null
#  code          :string(255)     not null
#  amount        :decimal(8, 2)   default(0.0)
#  minimum_value :decimal(8, 2)
#  percent       :integer(4)      default(0)
#  description   :text            default(""), not null
#  combine       :boolean(1)      default(FALSE)
#  starts_at     :datetime
#  expires_at    :datetime
#  created_at    :datetime
#  updated_at    :datetime
#

class Coupon < ApplicationRecord
  has_many :orders

  validates :code,          presence: true
  validates :minimum_value, presence: true
  validates :description,   presence: true
  validates :starts_at,     presence: true
  validates :expires_at,    presence: true

  COUPON_TYPES = ['CouponPercent', 'CouponValue','CouponFirstPurchasePercent', 'CouponFirstPurchaseValue']
  # order must respond to item_prices
  attr_accessor :c_type

  # amount the coupon will reduce the order
  def value(item_prices, order)
    qualified?(item_prices, order) ? coupon_amount(item_prices) : 0.0
  end

  # Does the coupon meet the criteria to apply it.  (is the order price total over the coupon's minimum value)
  def qualified?(item_prices, order, at = nil)
    at ||= order.completed_at || Time.zone.now
    item_prices.sum > minimum_value && eligible?(order, at)
  end

  def eligible?(order, at = nil)
    at ||= order.completed_at || Time.zone.now
    starts_at <= at && expires_at >= at
  end

  def display_start_time(format = :us_date)
    starts_at ? I18n.localize(starts_at, format: format) : 'N/A'
  end

  def display_expires_time(format = :us_date)
    expires_at ? I18n.localize(expires_at, format: format) : 'N/A'
  end

  private

  # dumby method to be called on the specific type of coupon  (single table inhertance)
  def coupon_amount(item_prices)
    (item_prices.sum >= minimum_value) ? amount : 0.0
  end

  # This is the value of the items that you will apply the coupon on.
  # for combine coupons you apply coupon to all the items
  # otherwise only apply the coupon to the max priced item
  def value_of_items_to_apply(item_prices)
    combine ? item_prices.sum : item_prices.max
  end
end
