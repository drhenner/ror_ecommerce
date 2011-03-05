class Account < ActiveRecord::Base

  FREE  = 'Free'
  TYPES = {FREE => 0.00}

  FREE_ID             = 1
  FREE_ACCOUNT_IDS    = [ FREE_ID ]

  validates :name,            :presence => true,       :length => { :maximum => 255 }
  validates :account_type,    :presence => true,       :length => { :maximum => 255 }
  validates :monthly_charge,  :presence => true


end
