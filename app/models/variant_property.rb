class VariantProperty < ApplicationRecord

  belongs_to :variant
  belongs_to :property

  validates :variant_id, uniqueness: { scope: :property_id }
  validates :property_id,  presence: true
  validates :description,  presence: true,       length: { maximum: 255 }


  # name of the property
  #
  # @param [none]
  # @return [String]
  def property_name
    property.display_name
  end
end
