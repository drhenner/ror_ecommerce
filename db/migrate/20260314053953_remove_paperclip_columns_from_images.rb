class RemovePaperclipColumnsFromImages < ActiveRecord::Migration[7.0]
  def change
    remove_column :images, :photo_file_name, :string
    remove_column :images, :photo_content_type, :string
    remove_column :images, :photo_file_size, :integer
    remove_column :images, :photo_updated_at, :datetime
  end
end
