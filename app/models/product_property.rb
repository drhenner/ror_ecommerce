class ProductProperty < ApplicationRecord
  belongs_to :product
  belongs_to :property

  validates :product_id,  uniqueness: { scope: :property_id }
  validates :property_id,   presence: true
end
