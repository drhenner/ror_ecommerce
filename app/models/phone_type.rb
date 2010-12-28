class PhoneType < ActiveRecord::Base
  has_many :phones

  validates :name, :presence => true

  # Type of possible phones, used in dropdowns and seed values
  NAMES = ['Cell', 'Home', 'Work', 'Other']

end
