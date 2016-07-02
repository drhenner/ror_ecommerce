class Newsletter < ApplicationRecord

  has_many    :users_newsletters, :dependent => :destroy
  has_many    :users, :through => :users_newsletters

  GENERAL_INFO        = 'General Information'
  AUTOSUBSCRIBED      = [GENERAL_INFO]
  MANUALLY_SUBSCRIBE  = []

end
