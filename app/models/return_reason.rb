class ReturnReason < ApplicationRecord
  has_many :return_items

  DEFECTIVE     = 'Defective'
  POOR_QUALITY  = 'Poor Quality'
  WRONG_ITEM    = 'Wrong Item'
  WRONG_SIZE    = 'Wrong Size/Color'
  ARRIVED_LATE  = 'Arrived too late'
  OTHER         = 'Other'

  REASONS = [DEFECTIVE, POOR_QUALITY, WRONG_ITEM, WRONG_SIZE, ARRIVED_LATE, OTHER]

  validates :label,     presence: true, length: { maximum: 255 }

  # method to get all the return reasons for a RMA form
  # [['Defective', 1], ['Dont like it', 2] ... ]
  #
  # @param [none]
  # @return [ Array[Array] ]
  def self.select_form
    all.collect {|r| [r.label, r.id]}
  end
end
