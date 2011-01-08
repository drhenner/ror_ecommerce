class Coupon < ActiveRecord::Base
  has_many :orders

  validates :code,  :presence => true,
                    :length => { :maximum => 50 }

  validates :type,          :presence => true
  validates :minimum_value, :presence => true


end
