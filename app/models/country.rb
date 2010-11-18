class Country < ActiveRecord::Base
  
  has_many :states
  
  validates :name,  :presence => true
  validates :abbreviation,  :presence => true
  
  USA_ID    = 214
  CANADA_ID = 35
  
end
