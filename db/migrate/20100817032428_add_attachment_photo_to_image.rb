class AddAttachmentPhotoToImage < ActiveRecord::Migration[4.2]
  def self.up
    add_column :images, :photo_file_name, :string
    add_column :images, :photo_content_type, :string
    add_column :images, :photo_file_size, :integer
    add_column :images, :photo_updated_at, :datetime
    add_column :images, :updated_at, :datetime
    add_column :images, :created_at, :datetime
  end

  def self.down
    remove_column :images, :photo_file_name
    remove_column :images, :photo_content_type
    remove_column :images, :photo_file_size
    remove_column :images, :photo_updated_at
    remove_column :images, :updated_at
    remove_column :images, :created_at
  end
end
