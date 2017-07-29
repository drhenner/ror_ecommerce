class CreateShippingRates < ActiveRecord::Migration[4.2]
  def self.up
    create_table :shipping_rates do |t|
      t.integer :shipping_method_id,    :null => false
      t.decimal :rate,                  :precision => 8, :scale => 2, :default => 0.0,  :null => false
      t.integer :shipping_rate_type_id, :null => false
      t.integer :shipping_category_id,  :null => false
      t.decimal :minimum_charge,        :precision => 8, :scale => 2, :default => 0.0,  :null => false
      t.integer :position
      t.boolean :active,                :default => true

      t.timestamps
    end
    add_index :shipping_rates, :shipping_category_id
    add_index :shipping_rates, :shipping_method_id
    add_index :shipping_rates, :shipping_rate_type_id
  end

  def self.down
    drop_table :shipping_rates
  end
end
