class CreateOrderItems < ActiveRecord::Migration[4.2]
  def self.up
    create_table :order_items do |t|
      t.decimal :price,      :precision => 8, :scale => 2
      t.decimal :total,      :precision => 8, :scale => 2
      t.integer :order_id,    :null => false
      t.integer :variant_id,  :null => false
      t.string :state,        :null => false
      t.integer :tax_rate_id
      t.integer :shipping_rate_id
      t.integer :shipment_id
      t.timestamps
    end

    add_index :order_items, :order_id
    add_index :order_items, :variant_id
    add_index :order_items, :tax_rate_id
    add_index :order_items, :shipping_rate_id
    add_index :order_items, :shipment_id
  end

  def self.down
    drop_table :order_items
  end
end
