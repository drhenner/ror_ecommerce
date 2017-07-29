class CreateInventories < ActiveRecord::Migration[4.2]
  def self.up
    create_table :inventories do |t|
      #t.integer :variant_id
      t.integer :count_on_hand,               :default => 0
      t.integer :count_pending_to_customer,   :default => 0
      t.integer :count_pending_from_supplier, :default => 0

      #t.timestamps
    end
  end

  def self.down
    drop_table :inventories
  end
end
