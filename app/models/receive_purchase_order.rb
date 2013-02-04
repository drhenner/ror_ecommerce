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

class ReceivePurchaseOrder < Transaction

  def self.new_direct_payment(purchase_order, total_cost, at = Time.zone.now)
    transaction = ReceivePurchaseOrder.new()
    transaction.transaction_ledgers.push( purchase_order.new_credit(TransactionAccount::CASH_ID, total_cost, at) )
    transaction.transaction_ledgers.push( purchase_order.new_debit(TransactionAccount::EXPENSE_ID, total_cost, at) )
    transaction
  end

  def self.new_expensed(purchase_order, total_cost, at = Time.zone.now)
    transaction = ReceivePurchaseOrder.new()
    transaction.transaction_ledgers.push(purchase_order.new_credit(TransactionAccount::CASH_ID, total_cost, at))
    transaction.transaction_ledgers.push(purchase_order.new_debit(TransactionAccount::ACCOUNTS_PAYABLE_ID, total_cost, at))
    transaction
  end

  def self.new_expensed_payment(purchase_order, total_cost, at = Time.zone.now)
    transaction = ReceivePurchaseOrder.new()
    transaction.transaction_ledgers.push( purchase_order.new_credit(TransactionAccount::ACCOUNTS_PAYABLE_ID, total_cost, at) )
    transaction.transaction_ledgers.push( purchase_order.new_debit(TransactionAccount::EXPENSE_ID, total_cost, at) )
    transaction
  end


end
