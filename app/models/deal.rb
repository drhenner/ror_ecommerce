# The deal model is basically a "buy X get y percent free" or "buy X get y dollars off"
#
# In the scenario "buy X get y percent free", X is buy_quantity and y is get_percentage.  The way it works get_percentage is multiplied by the lowest costing item that "qualifies" for the deal.
#
### NOTE: "qualifies" =>  a product qualifies if is of the correct product_type_id.  If the product_type_id doesn't match it will not qualify.  so you might have three pants but also one belt.  the belt and the pants will not be the same product_type_id.

# In the scenario "buy X get y dollars off", X is buy_quantity and y is get_amount.  The way it works get_amount is the number of cents reduced from the order total.   Again the NOTE above about "qualifies" still is in effect

# == Schema Information
#
# Table name: deals
#
#  id              :integer          not null, primary key
#  buy_quantity    :integer          not null
#  get_percentage  :integer
#  deal_type_id    :integer          not null
#  product_type_id :integer          not null
#  get_amount      :integer
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Deal < ActiveRecord::Base
  attr_accessible :buy_quantity, :deal_type_id, :get_percentage, :product_type_id, :get_amount, :deleted_at

  validates :buy_quantity,            :presence => true
  validates :get_percentage,          :presence => true, :if => :get_amount_is_blank?
  validates :product_type_id,         :presence => true
  validates :get_amount,              :presence => true, :if => :get_percentage_is_blank?

  belongs_to :deal_type
  belongs_to :product_type

  def self.best_qualifing_deal(order)
    product_type_and_amount_hash = order.number_of_a_given_product_type.sort_by{|v| v.last.size }.reverse
    deal_time = order.completed_at || Time.zone.now # Deal.best_qualifing_deal(ooo)
    product_type_and_amount_hash.each do |h|
      deal_amount = qualifing_deal(h, deal_time)
      return deal_amount.round_at(2) if deal_amount
    end
    0.0
  end
  def self.qualifing_deal(h, at)
    deal = self.where(['deals.buy_quantity <= ?', h.last.size]).
    where(['deals.product_type_id IN (?)', h.first]).
    where(['deals.created_at <= ?', at]).where(['deals.deleted_at >= ? OR deals.deleted_at IS NULL', at]).
    order('deals.get_percentage DESC').first
    if deal && deal.get_amount && deal.get_amount > 0.0
      deal.get_amount.to_f / 100.0
    else
      deal ?  ((h.last.sort.reverse[0..(deal.buy_quantity - 1)].min) * deal.get_percentage).to_f / 100.0 : false
    end
  end

  # [item1.price,item2.price,item3.price ].sort.reverse[0..4].min

  private
    def get_percentage_is_blank?
      get_percentage.blank?
    end
    def get_amount_is_blank?
      get_amount.blank?
    end
end