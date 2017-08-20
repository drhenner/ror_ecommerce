class ReturnCondition < ApplicationRecord
  has_many :return_items

  GOOD      = 'Good'
  DEFECTIVE = 'Defective'
  DAMAGED   = 'Worn / Damaged'

  CONDITIONS = [GOOD, DEFECTIVE, DAMAGED]

  validates :label,      presence: true, :length => { :maximum => 255 }

  # method to get all the return conditions for a RMA form
  # [['Good', 1], ['Defective', 2] ... ]
  #
  # @param [none]
  # @return [ Array[Array] ]
  def self.select_form
    all.collect {|r| [r.label, r.id]}
  end

end
