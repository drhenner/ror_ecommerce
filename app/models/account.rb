class Account < ActiveRecord::Base

  FREE  = 'Free'
  TYPES = {FREE => 0.00}

  FREE_ID             = 1
  FREE_ACCOUNT_IDS    = [ FREE_ID ]

  validates :name,            :presence => true
  validates :account_type,    :presence => true
  validates :monthly_charge,  :presence => true


end
