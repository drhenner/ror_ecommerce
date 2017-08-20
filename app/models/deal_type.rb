class DealType < ApplicationRecord

  validates :name,            presence: true

  has_many :deals
  TYPES = ['Buy X Get % off', 'Buy X Get $ off']
end
