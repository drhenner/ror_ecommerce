# == Schema Information
#
# Table name: transactions
#
#  id         :integer(4)      not null, primary key
#  type       :string(255)
#  batch_id   :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class ReturnMerchandiseComplete < Transaction
  def self.new_complete_rma(transacting_user, total_cost, at = Time.zone.now)
    transaction = ReturnMerchandiseComplete.new()
    transaction.new_transaction_ledgers( transacting_user, TransactionAccount::CASH_ID, TransactionAccount::REVENUE_ID, total_cost, at)
    transaction
  end
end
