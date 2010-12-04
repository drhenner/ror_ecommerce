require 'paperclip'

class Image < ActiveRecord::Base
  belongs_to :imageable, :polymorphic => true
  
  has_attached_file :photo, 
                    :styles => { :mini => '48x48>', :small => '100x100>', :product => '320x320>', :large => '600x600>' }, 
                    :default_style => :product,
                    :url => "/assets/products/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/assets/products/:id/:style/:basename.:extension"
#image_tag @product.photo.url(:small)
  validates_attachment_presence :photo
  validates_attachment_size     :photo, :less_than => 5.megabytes
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png']
  
  validates :imageable_type,  :presence => true
  validates :imageable_id,    :presence => true
  
  default_scope :order => 'position'
  
  # save the w,h of the original image (from which others can be calculated)
  after_post_process :find_dimensions
  MAIN_LOGO = 'logo2'
  
  def find_dimensions
    temporary = photo.queued_for_write[:original] 
    filename = temporary.path unless temporary.nil?
    filename = photo.path if filename.blank?
    geometry = Paperclip::Geometry.from_file(filename)
    self.image_width  = geometry.width
    self.image_height = geometry.height
  end
  
  # if there are errors from the plugin, then add a more meaningful message
  def validate
    unless photo.errors.empty?
      # uncomment this to get rid of the less-than-useful interrim messages
      # errors.clear 
      errors.add :attachment, "Paperclip returned errors for file '#{photo_file_name}' - check ImageMagick installation or image source file."
      false
    end
  end
end
