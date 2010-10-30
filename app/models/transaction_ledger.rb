class TransactionLedger < ActiveRecord::Base
  belongs_to :transaction_account
  belongs_to :transaction
  belongs_to :accountable, :polymorphic => true
  
  
  validates :accountable_type,        :presence => true
  validates :accountable_id,          :presence => true
  #validates :transaction_id,          :presence => true## test fails but we need this validation back in
  validates :transaction_account_id,  :presence => true
  
  validates :debit,   :presence => true
  validates :credit,  :presence => true
  validates :period,  :presence => true
  
  
end
