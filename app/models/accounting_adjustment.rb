# == Schema Information
#
# Table name: accounting_adjustments
#
#  id              :integer(4)      not null, primary key
#  adjustable_id   :integer(4)      not null
#  adjustable_type :string(255)     not null
#  notes           :string(255)
#  amount          :decimal(8, 2)   not null
#  created_at      :datetime
#  updated_at      :datetime
#

class AccountingAdjustment < ActiveRecord::Base

  has_many  :batches,             :as => :batchable
  has_many  :transaction_ledgers, :as => :accountable

  validates :amount,      :presence => true
  def self.adjust_stock(inventory, qty_to_add, return_amount)
    transaction do
      accounting_adjustment = inventory.accounting_adjustments.create(:amount => return_amount, :notes => '')
      inventory.count_on_hand = inventory.count_on_hand.to_i + qty_to_add.to_i
      inventory.save
      accounting_adjustment.refund_inventory
    end
  end

  def refund_inventory
    now = Time.zone.now
    batch = self.batches.create()
    transaction = RefundInventory.new()##  This is a type of transaction
    credit = self.transaction_ledgers.new(:transaction_account_id => TransactionAccount::EXPENSE_ID,  :debit => 0,      :credit => amount, :period => "#{now.month}-#{now.year}")
    debit  = self.transaction_ledgers.new(:transaction_account_id => TransactionAccount::CASH_ID,     :debit => amount, :credit => 0,      :period => "#{now.month}-#{now.year}")
    transaction.transaction_ledgers.push(credit)
    transaction.transaction_ledgers.push(debit)
    batch.transactions.push(transaction)
    batch.save
  end

end
