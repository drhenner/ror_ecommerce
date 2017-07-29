class CreateImageGroups < ActiveRecord::Migration[4.2]
  def self.up
    create_table :image_groups do |t|
      t.string :name,         :null => false
      t.integer :product_id,  :null => false
      t.timestamps
    end
    add_index :image_groups, :product_id
  end

  def self.down
    drop_table :image_groups
  end
end
