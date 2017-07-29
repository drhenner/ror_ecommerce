class CreateImages < ActiveRecord::Migration[4.2]
  def self.up
    create_table :images do |t|
      t.integer :imageable_id
      t.string  :imageable_type
      t.integer :image_height
      t.integer :image_width
      t.integer :position
      t.string  :caption
    end
    add_index :images, :imageable_id
    add_index :images, :imageable_type
    add_index :images, :position
  end

  def self.down
    drop_table :images
  end
end
