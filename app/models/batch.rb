class Batch < ActiveRecord::Base
  belongs_to :batchable, :polymorphic => true
  has_many   :transactions
  
  
  validates :batchable_type,  :presence => true
  validates :batchable_id,    :presence => true
  
end
