class Country < ActiveRecord::Base
  
  has_many :states
  
  validates :name,  :presence => true
  validates :abbreviation,  :presence => true
  
  USA_ID    = 1
  CANADA_ID = 2
  
end
