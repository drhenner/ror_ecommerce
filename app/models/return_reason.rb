class ReturnReason < ActiveRecord::Base
  has_many :return_items
  
  DEFECTIVE     = 'Defective'
  POOR_QUALITY  = 'Poor Quality'
  WRONG_ITEM    = 'Wrong Item'
  WRONG_SIZE    = 'Wrong Size/Color'
  ARRIVED_LATE  = 'Arrived to late'
  OTHER         = 'Other'
  
  REASONS = [DEFECTIVE, POOR_QUALITY, WRONG_ITEM, WRONG_SIZE, ARRIVED_LATE, OTHER]
  
  validates :label,     :presence => true
  
  def self.select_form
    all.collect {|r| [r.label, r.id]}
  end
end
