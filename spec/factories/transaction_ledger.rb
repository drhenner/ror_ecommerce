
Factory.define :transaction_ledger do |f|
  f.accountable         { |c| c.association(:user) }
  f.transaction         { |c| c.association(:transaction) }
  f.transaction_account { TransactionAccount.first }
  f.tax_amount          0.00
  f.debit               10.98
  f.credit              0.00
  f.period              '9-2010'
end