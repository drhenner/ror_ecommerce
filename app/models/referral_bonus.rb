# create_table "referral_bonus", :force => true do |t|
#   t.string   "name"
#   t.integer  "quantity_needed", :null => false
#   t.integer  "amount",          :null => false
#   t.datetime "created_at",      :null => false
#   t.datetime "updated_at",      :null => false
# end

class ReferralBonus < ApplicationRecord
  self.table_name = 'referral_bonuses'
  has_many :referral_programs

  validates :name,              presence: true,       :length => { :maximum => 70 }
  validates :amount,            presence: true

  BONUSES = [
      { :name             => '$5 per Referral',
        :amount           => 500
      }
    ]
  def give_credits(user)
    user.store_credit.add_credit(decimal_amount)
  end

  def decimal_amount
    (amount.to_f / 100.0).round_at(2)
  end

end
