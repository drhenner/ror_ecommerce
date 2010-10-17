class PhoneType < ActiveRecord::Base
  has_many :phones
  
  validates :name, :presence => true
  
  NAMES = ['Cell', 'Home', 'Work', 'Other']
  
end
