class CreateProductTypes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :product_types do |t|

      t.string    :name, :null => false
      t.integer   :parent_id
      t.boolean   :active, :default => true
    end

    add_index :product_types, :parent_id
  end

  def self.down
    drop_table :product_types
  end
end
