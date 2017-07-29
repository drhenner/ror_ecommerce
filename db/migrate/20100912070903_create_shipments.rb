class CreateShipments < ActiveRecord::Migration[4.2]
  def self.up
    create_table :shipments do |t|
      t.integer :order_id
      t.integer :shipping_method_id, :null => false
      t.integer :address_id, :null => false
      t.string :tracking
      t.string :number, :null => false
      t.string :state, :null => false
      t.datetime :shipped_at
      t.boolean  :active, :default => true, :null => false
      t.timestamps
    end

    add_index :shipments, :shipping_method_id
    add_index :shipments, :address_id
    add_index :shipments, :order_id
    add_index :shipments, :number
  end

  def self.down
    drop_table :shipments
  end
end
#rails g CreditCard first_name:string last_name:string month:string year:string cc_type:string number:string address_id:integer
