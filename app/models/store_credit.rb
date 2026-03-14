# == Schema Information
#
# Table name: store_credits
#
#  id         :integer(4)      not null, primary key
#  amount     :decimal(8, 2)   default(0.0)
#  user_id    :integer(4)      not null
#  created_at :datetime
#  updated_at :datetime
#

class StoreCredit < ApplicationRecord

  belongs_to :user

  validates :user_id, presence: true
  validates :amount , presence: true

  after_find :ensure_sql_math_rounding_issues
  # removes amount from object using SQL math
  #
  # @param [Float] amount to remove
  # @return [none]
  def remove_credit(amount_to_remove)
    return if amount_to_remove.to_f <= 0
    StoreCredit.where(id: id).update_all(["amount = GREATEST(amount - ?, 0)", amount_to_remove.to_f.round_at(2)])
  end

  def add_credit(amount_to_add)
    StoreCredit.where(id: id).update_all(["amount = amount + ?", amount_to_add.to_f.round_at(2)])
  end

  private

  def ensure_sql_math_rounding_issues
    self.amount = amount.to_f.round_at(2)
  end
end
