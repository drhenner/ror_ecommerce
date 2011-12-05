# == Schema Information
#
# Table name: batches
#
#  id             :integer(4)      not null, primary key
#  batchable_type :string(255)
#  batchable_id   :integer(4)
#  name           :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

class Batch < ActiveRecord::Base
  belongs_to :batchable, :polymorphic => true
  has_many   :transactions
  
  
  validates :batchable_type,  :presence => true
  validates :batchable_id,    :presence => true
  
end
