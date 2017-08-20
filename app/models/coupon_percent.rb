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

class CouponPercent < Coupon

  validates :percent, presence: true

  private

  def coupon_amount(item_prices)
    ( value_of_items_to_apply(item_prices) * ( percent.to_f / 100.0 ) ).round_at(2)
  end

end
