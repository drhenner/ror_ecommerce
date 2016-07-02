class ReferralType < ApplicationRecord
  has_many :referrals

  validates :name,      :presence => true

  DIRECT_WEB_FORM = 'Directly through Web Form'
  ADMIN_WEB_FORM  = 'Admin Web Form'
  NAMES = [ DIRECT_WEB_FORM, ADMIN_WEB_FORM]

  DIRECT_WEB_FORM_ID  = 1
  ADMIN_WEB_FORM_ID  = 2
end
