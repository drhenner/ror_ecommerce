module TransactionAccountable

  def new_credit(transaction_account_id, credit_amount, at = Time.zone.now)
    credit = self.transaction_ledgers.new(:transaction_account_id => transaction_account_id, :debit => 0, :credit => credit_amount, :period => "#{at.month}-#{at.year}")
    credit
  end

  def new_debit(transaction_account_id, debit_amount, at = Time.zone.now)
    debit = self.transaction_ledgers.new(:transaction_account_id => transaction_account_id, :debit => 0, :credit => debit_amount, :period => "#{at.month}-#{at.year}")
    debit
  end
end
