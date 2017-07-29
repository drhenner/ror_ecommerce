class AddBrandIdToVariants < ActiveRecord::Migration[4.2]
  def self.up
    add_column :variants, :brand_id, :integer
    add_index :variants,  :brand_id
  end

  def self.down
    remove_column :variants, :brand_id
  end
end
