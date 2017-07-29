class AddNestedSetToProductTypes < ActiveRecord::Migration[4.2]
  def self.up
    add_column :product_types, :rgt, :integer
    add_column :product_types, :lft, :integer

    add_index :product_types, :lft
    add_index :product_types, :rgt

    ProductType.reset_column_information
    #ProductType.rebuild!
  end

  def self.down
    remove_column :product_types, :rgt
    remove_column :product_types, :lft
  end
end
