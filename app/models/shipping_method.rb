# == Schema Information
#
# Table name: shipping_methods
#
#  id               :integer(4)      not null, primary key
#  name             :string(255)     not null
#  shipping_zone_id :integer(4)      not null
#  created_at       :datetime
#  updated_at       :datetime
#

class ShippingMethod < ApplicationRecord
  has_many :shipping_rates
  belongs_to :shipping_zone

  validates  :name,  presence: true, length: { maximum: 255 }
  validates  :shipping_zone_id,  presence: true

  def descriptive_name
    "#{name} (#{shipping_zone.name})"
  end
end
