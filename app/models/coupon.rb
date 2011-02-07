class Coupon < ActiveRecord::Base
  has_many :orders

  validates :code,          :presence => true
  validates :minimum_value, :presence => true
  validates :description,   :presence => true
  validates :starts_at,     :presence => true
  validates :expires_at,    :presence => true

  COUPON_TYPES = ['coupon_percent', 'coupon_value']
  # order must respond to item_prices

  # amount the coupon will reduce the order
  def value(item_prices)
    qualified?(item_prices) ? coupon_amount(item_prices) : 0.0
  end

  # Does the coupon meet the criteria to apply it.  (is the order price total over the coupon's minimum value)
  def qualified?(item_prices)
    item_prices.sum > minimum_value
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
    0.0
  end

  # This is the value of the items that you will apply the coupon on.
  # for combine coupons you apply coupon to all the items
  # otherwise only apply the coupon to the max priced item
  def value_of_items_to_apply(item_prices)
    combine ? item_prices.sum : item_prices.max
  end
end
