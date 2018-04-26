# BATCH DOCUMENTATION
#
# The users table represents...  BATCHS!!!
#
# OK Now that doesn't appear to make any sence...  It is actually not very easy to understand without context.

# A BATCH entry reflects the more physical aspects of accounting data entry. It is used to group
# together transactions entries into handy ‘chunks’, for example, a collection of cheques to be
# entered into the system...  OR in this app's case all the transactions grouped for one order.

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

class Batch < ApplicationRecord
  belongs_to :batchable, polymorphic: true
  has_many   :transactions


  validates :batchable_type,  presence: true
  validates :batchable_id,    presence: true

end
