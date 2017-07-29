class CreateDeals < ActiveRecord::Migration[4.2]
  def change
    create_table :deals do |t|
      t.integer :buy_quantity,    :null => false
      t.integer :get_percentage
      t.integer :deal_type_id,    :null => false
      t.integer :product_type_id, :null => false
      t.integer :get_amount
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :deals, :deal_type_id
    add_index :deals, :product_type_id
    add_index :deals, :buy_quantity
  end
end
