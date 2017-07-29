class CreatePurchaseOrderVariants < ActiveRecord::Migration[4.2]
  def self.up
    create_table :purchase_order_variants do |t|
      t.integer :purchase_order_id, :null => false
      t.integer :variant_id,        :null => false
      t.integer :quantity,          :null => false
      t.decimal :cost,              :null => false,      :precision => 8, :scale => 2
      t.boolean :is_received,       :default => false
      t.timestamps
    end

    add_index :purchase_order_variants, :purchase_order_id
    add_index :purchase_order_variants, :variant_id
  end

  def self.down
    drop_table :purchase_order_variants
  end
end
