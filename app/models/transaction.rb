class Transaction < ActiveRecord::Base
  belongs_to :batch
  
  has_many :transaction_ledgers
  
  validates :batch_id,    :presence => true
  validates :type,        :presence => true
end
