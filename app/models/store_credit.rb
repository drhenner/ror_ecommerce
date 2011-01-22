class StoreCredit < ActiveRecord::Base
  attr_accessible :amount, :user_id

  belongs_to :user

  validates :user_id, :presence => true
  validates :amount , :presence => true

  # removes amount from object using SQL math
  #
  # @param [Float] amount to remove
  # @return [none]
  def remove_credit(amount_to_remove)
    sql = "UPDATE store_credits SET amount = (amount - #{amount_to_remove}) WHERE id = #{self.id}"
    ActiveRecord::Base.connection.execute(sql)
  end
end
