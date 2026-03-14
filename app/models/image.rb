# == Schema Information
#
# Table name: images
#
#  id                 :integer(4)      not null, primary key
#  imageable_id       :integer(4)
#  imageable_type     :string(255)
#  image_height       :integer(4)
#  image_width        :integer(4)
#  position           :integer(4)
#  caption            :string(255)
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  photo_file_size    :integer(4)
#  photo_updated_at   :datetime
#  updated_at         :datetime
#  created_at         :datetime
#

require 'open-uri'

class Image < ApplicationRecord
  belongs_to :imageable, :polymorphic => true

  has_one_attached :photo

  IMAGE_STYLES = {
    mini:    { resize_to_limit: [48, 48] },
    small:   { resize_to_limit: [100, 100] },
    medium:  { resize_to_limit: [200, 200] },
    product: { resize_to_limit: [320, 320] },
    large:   { resize_to_limit: [600, 600] }
  }.freeze

  validates :imageable_type, presence: true
  validates :imageable_id,   presence: true
  validate  :validate_photo

  attr_accessor :photo_link

  default_scope -> { order('position') }

  after_save :find_dimensions, if: -> { photo.attached? && photo.blob.previously_new_record? }

  MAIN_LOGO = 'logo'

  def photo_from_link=(val)
    if !val.blank?
      self.photo_link = val
      downloaded = URI.open(val)
      photo.attach(io: downloaded, filename: File.basename(val))
    end
  end

  def photo_from_link
    self.photo_link || ''
  end

  def photo_url(size = :product)
    return nil unless photo.attached?
    if IMAGE_STYLES.key?(size)
      photo.variant(IMAGE_STYLES[size])
    else
      photo
    end
  end

  private

  def find_dimensions
    return unless photo.attached?
    photo.blob.analyze unless photo.blob.analyzed?
    metadata = photo.blob.metadata
    if metadata[:width] && metadata[:height]
      update_columns(image_width: metadata[:width], image_height: metadata[:height])
    end
  end

  def validate_photo
    unless photo.attached?
      errors.add(:photo, "must be attached")
    end
  end
end
