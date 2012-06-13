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

class Coupon < ActiveRecord::Base
  has_many :orders

  validates :code,          :presence => true
  validates :minimum_value, :presence => true
  validates :description,   :presence => true
  validates :starts_at,     :presence => true
  validates :expires_at,    :presence => true

  COUPON_TYPES = ['coupon_percent', 'coupon_value']
  # order must respond to item_prices
  attr_accessor :c_type

  # amount the coupon will reduce the order
  def value(item_prices, order)
    qualified?(item_prices, order) ? coupon_amount(item_prices) : 0.0
  end

  # Does the coupon meet the criteria to apply it.  (is the order price total over the coupon's minimum value)
  def qualified?(item_prices, order, at = nil)
    at ||= order.completed_at || Time.zone.now
    item_prices.sum > minimum_value && eligible?(at)
  end

  def eligible?(order, at = nil)
    at ||= order.completed_at || Time.zone.now
    starts_at <= at && expires_at >= at
  end

  def display_start_time(format = :us_date)
    starts_at ? I18n.localize(starts_at, :format => format) : 'N/A'
  end

  def display_expires_time(format = :us_date)
    expires_at ? I18n.localize(expires_at, :format => format) : 'N/A'
  end

  private

  # dumby method to be called on the specific type of coupon  (single table inhertance)
  def coupon_amount(item_prices)
    (item_prices >= minimum_value) ? amount : 0.0
  end

  # This is the value of the items that you will apply the coupon on.
  # for combine coupons you apply coupon to all the items
  # otherwise only apply the coupon to the max priced item
  def value_of_items_to_apply(item_prices)
    combine ? item_prices.sum : item_prices.max
  end
end
