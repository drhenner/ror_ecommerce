class Account < ActiveRecord::Base
  
  FREE  = 'Free'
  TYPES = {FREE => 0.00}
  
  validates :name,            :presence => true
  validates :account_type,    :presence => true
  validates :monthly_charge,  :presence => true
  
  
end
