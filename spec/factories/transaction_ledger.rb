FactoryGirl.define do
  factory :transaction_ledger do
    accountable         { |c| c.association(:user) }
    transactionn        { |c| c.association(:transaction) }
    transaction_account { TransactionAccount.first }
    tax_amount          0.00
    debit               10.98
    credit              0.00
    period              '9-2010'
  end
end
