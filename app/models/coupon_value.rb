class CouponValue < Coupon

  validates :amount, :presence => true

  private

  def coupon_amount(item_prices)
    amount
  end
end