# Typically a product has many variants.  (Variant ~= specific size of a given shoe)
#
# If you have many variants with the same image don't bother with an image group,
#  just use the "products.images".
#
# Use ImageGroups for something like shoes. Lets say you have 3 colors, and each color has 10 sizes.
#  You would create 3 images groups (one for each color). The image for each size would be the same and
#  hence each variant would be associated to the same image_group for a given color.
#

class ImageGroup < ApplicationRecord
  validates :name,        presence: true
  validates :product_id,  presence: true

  belongs_to :product
  has_many :variants
  has_many :images, -> {order(:position)},
                    as:        :imageable,
                    dependent: :destroy
  after_save :expire_cache

  accepts_nested_attributes_for :images, reject_if: proc { |t| ((t['photo'].nil? && t['photo_from_link'].blank?) && t['id'].blank?) }, allow_destroy: true

  def image_urls(image_size = :small)
    Rails.cache.fetch("ImageGroup-image_urls-#{id}-#{image_size}", :expires_in => 3.hours) do
      images.empty? ? product.image_urls(image_size) : images.map{|i| i.photo.url(image_size)}
    end
  end

  private
    def expire_cache
      PAPERCLIP_STORAGE_OPTS[:styles].each_pair do |image_size, value|
        Rails.cache.delete("ImageGroup-image_urls-#{id}-#{image_size}")
      end
    end
end
