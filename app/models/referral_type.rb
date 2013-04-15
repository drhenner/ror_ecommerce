class ReferralType < ActiveRecord::Base
  attr_accessible :name
  has_many :referrals

  validates :name,      :presence => true

  DIRECT_WEB_FORM = 'Directly through Web Form'
  NAMES = [ DIRECT_WEB_FORM]

  DIRECT_WEB_FORM_ID  = 1
end
