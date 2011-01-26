class CouponPercent < Coupon

  validates :percent, :presence => true

  private

  def coupon_amount(item_prices)
    ( value_of_items_to_apply(item_prices) * ( percent.to_f / 100.0 ) ).round_at(2)
  end

end