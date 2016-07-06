# ACCOUNTING ADJUSTMENTS DOCUMENTATION
#
# The users table represents...  ACCOUNTING ADJUSTMENTS!!!
#
#  In accounting you might need to account for missing stock or for some reason an
#  extra item pops up in stock.  So a warehouse person would need to go into the app
#  and add the inventory to stock (or subtract).  This adjustment also adjusts account.
#  It is WAY beyond the scope of this documentation to explain Double entry accounting...
#  (Please look here: http://www.dwmbeancounter.com/tutorial/Tutorial.html)

# This model adds an extra log to view the notes and amount associated with this specific
# type of "accounting adjustment".  This table could be used in a report for your accountant.

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

class AccountingAdjustment < ApplicationRecord

  has_many  :batches,             :as => :batchable
  has_many  :transaction_ledgers, :as => :accountable

  validates :amount,      :presence => true
  def self.adjust_stock(inventory, qty_to_add, return_amount)
    transaction do
      accounting_adjustment = inventory.accounting_adjustments.create(:amount => return_amount, :notes => '')
      inventory.add_count_on_hand(qty_to_add)
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
