# == Schema Information
#
# Table name: transaction_accounts
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class TransactionAccount < ApplicationRecord
  has_many :transaction_ledgers
  REVENUE             = 'Revenue'
  ACCOUNTS_RECEIVABLE = 'Accounts Receivable'
  ACCOUNTS_PAYABLE    = 'Accounts Payable'
  CASH                = 'Cash'
  EXPENSE             = 'Expense'

  REVENUE_ID              = 1
  ACCOUNTS_RECEIVABLE_ID  = 2
  ACCOUNTS_PAYABLE_ID     = 3
  CASH_ID                 = 4
  EXPENSE_ID              = 5

  ACCOUNT_TYPES = [REVENUE, ACCOUNTS_RECEIVABLE, ACCOUNTS_PAYABLE, CASH, EXPENSE]

  validates :name,            presence: true, length: { maximum: 255 }

end
