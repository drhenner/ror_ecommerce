# ACCOUNT DOCUMENTATION
#
# The Accounts table represents... drum role please...  ACCOUNTS!!!
#
# The purpose is for a subscription based service.
#
# Example 1:
#    Someone signs up for a service with a monthly fee as opposed to one lump some.  The fee for the service
#    to be charged $25 per month.

#  NOTE: This has not been implemented and it is an option to delete this model if that is the desire
#

# == Schema Information
#
# Table name: accounts
#
#  id             :integer          not null, primary key
#  name           :string(255)      not null
#  account_type   :string(255)      not null
#  monthly_charge :decimal(8, 2)    default(0.0), not null
#  active         :boolean          default(TRUE), not null
#  created_at     :datetime
#  updated_at     :datetime
#


class Account < ApplicationRecord

  FREE  = 'Free'
  TYPES = {FREE => 0.00}

  FREE_ID             = 1
  FREE_ACCOUNT_IDS    = [ FREE_ID ]

  validates :name,            :presence => true,       :length => { :maximum => 255 }
  validates :account_type,    :presence => true,       :length => { :maximum => 255 }
  validates :monthly_charge,  :presence => true


end
