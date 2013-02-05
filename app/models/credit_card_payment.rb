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

class CreditCardPayment < Transaction
  def self.new_authorized_payment(transacting_user, total_cost, at = Time.zone.now)
    transaction = CreditCardPayment.new()
    transaction.new_transaction_ledgers( transacting_user, TransactionAccount::REVENUE_ID, TransactionAccount::ACCOUNTS_RECEIVABLE_ID, total_cost, at)
    transaction
  end
end
