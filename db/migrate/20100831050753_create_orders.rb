class CreateOrders < ActiveRecord::Migration[4.2]
  def self.up
    create_table :orders do |t|
      t.string :number
      t.string :ip_address
      t.string :email
      t.string :state
      t.integer :user_id
      t.integer :bill_address_id
      t.integer :ship_address_id
      t.integer :coupon_id
      t.boolean :active, :default => true, :null => false
      t.boolean :shipped, :default => false, :null => false
      t.integer :shipment_counter, :default => 0
      t.datetime :calculated_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :orders, :number
    add_index :orders, :email
    add_index :orders, :user_id
    add_index :orders, :bill_address_id
    add_index :orders, :ship_address_id
    add_index :orders, :coupon_id
  end

  def self.down
    drop_table :orders
  end
end
