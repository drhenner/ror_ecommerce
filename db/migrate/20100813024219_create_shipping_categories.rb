class CreateShippingCategories < ActiveRecord::Migration[4.2]
  def self.up
    create_table :shipping_categories do |t|
      t.string :name, :null => false,   :unique => true
      #t.integer :product_id, :null => false
      #t.integer :shipping_rate_id, :null => false
      #t.timestamps
    end
  end

  def self.down
    drop_table :shipping_categories
  end
end
