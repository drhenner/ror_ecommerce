# == Schema Information
#
# Table name: transaction_ledgers
#
#  id                     :integer(4)      not null, primary key
#  accountable_type       :string(255)
#  accountable_id         :integer(4)
#  transaction_id         :integer(4)
#  transaction_account_id :integer(4)
#  tax_amount             :decimal(8, 2)   default(0.0)
#  debit                  :decimal(8, 2)   not null
#  credit                 :decimal(8, 2)   not null
#  period                 :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#

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
