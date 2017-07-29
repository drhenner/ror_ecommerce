class CreateShippingMethods < ActiveRecord::Migration[4.2]
  def self.up
    create_table :shipping_methods do |t|
      t.string :name, :null => false
      t.integer :shipping_zone_id, :null => false

      t.timestamps
    end
    add_index :shipping_methods, :shipping_zone_id
  end

  def self.down
    drop_table :shipping_methods
  end
end
