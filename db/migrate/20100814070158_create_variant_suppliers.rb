class CreateVariantSuppliers < ActiveRecord::Migration[4.2]
  def self.up
    create_table :variant_suppliers do |t|
      t.integer     :variant_id,                                            :null => false
      t.integer     :supplier_id,                                           :null => false
      t.decimal      :cost, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.integer      :total_quantity_supplied,            :default => 0
      t.integer      :min_quantity,                       :default => 1
      t.integer      :max_quantity,                       :default => 10000
      t.boolean     :active,                              :default => true
      t.timestamps
    end

    add_index :variant_suppliers, :variant_id
    add_index :variant_suppliers, :supplier_id
  end

  def self.down
    drop_table :variant_suppliers
  end
end
