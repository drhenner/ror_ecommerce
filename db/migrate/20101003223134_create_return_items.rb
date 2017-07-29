class CreateReturnItems < ActiveRecord::Migration[4.2]
  def self.up
    create_table :return_items do |t|
      t.integer :return_authorization_id, :null => false
      t.integer :order_item_id,           :null => false
      t.integer :return_condition_id
      t.integer :return_reason_id
      t.boolean :returned, :default => false
      t.integer :updated_by

      t.timestamps
    end
    add_index :return_items, :return_authorization_id
    add_index :return_items, :order_item_id
    add_index :return_items, :return_condition_id
    add_index :return_items, :return_reason_id
    add_index :return_items, :updated_by
  end

  def self.down
    drop_table :return_items
  end
end
