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

class CreditCardCapture < Transaction

  def self.new_capture_payment_directly(transacting_user, total_cost, at = Time.zone.now)
    transaction = CreditCardCapture.new()
    transaction.new_transaction_ledgers( transacting_user, TransactionAccount::REVENUE_ID, TransactionAccount::CASH_ID, total_cost, at)
    transaction
  end
end
