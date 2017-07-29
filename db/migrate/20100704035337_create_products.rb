class CreateProducts < ActiveRecord::Migration[4.2]
  def self.up
    create_table :products do |t|
      t.string            :name,                  :null => false
      t.text              :description
      t.text              :product_keywords
      t.integer           :product_type_id,       :null => false
      t.integer           :prototype_id
      t.integer           :shipping_category_id,  :null => false
      t.string            :permalink,             :null => false
      t.datetime          :available_at
      t.datetime          :deleted_at
      t.string            :meta_keywords
      t.string            :meta_description
      t.boolean           :featured,          :default => false
      t.timestamps
    end
      add_index :products, :name
      add_index :products, :product_type_id
      add_index :products, :shipping_category_id
      add_index :products, :prototype_id
      add_index :products, :deleted_at
      add_index :products, :permalink,   :unique => true
  end

  def self.down
    drop_table :products
  end
end
