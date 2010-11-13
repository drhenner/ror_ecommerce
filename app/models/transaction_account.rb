class TransactionAccount < ActiveRecord::Base
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
  
  validates :name,              :presence => true
  
end
