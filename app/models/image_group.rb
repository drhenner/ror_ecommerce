# Image groups allow any variant to have "variant specific" images.  Thus a red shit would show as red an not green.

class ImageGroup < ActiveRecord::Base
  #attr_accessible :name, :product_id, :images_attributes

  validates :name,        presence: true
  validates :product_id,  presence: true

  belongs_to :product
  has_many :variants
  has_many :images, -> {order(:position)},
                    :as         => :imageable,
                    :dependent  => :destroy
  after_save :expire_cache

  accepts_nested_attributes_for :images, :reject_if => proc { |t| (t['photo'].nil? && t['photo_from_link'].blank?) }, :allow_destroy => true

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
