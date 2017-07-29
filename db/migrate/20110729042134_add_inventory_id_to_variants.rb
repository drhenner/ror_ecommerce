class AddInventoryIdToVariants < ActiveRecord::Migration[4.2]
  def self.up
    add_column :variants, :inventory_id, :integer
    remove_column :variants, :count_on_hand
    remove_column :variants, :count_pending_to_customer
    remove_column :variants, :count_pending_from_supplier

    add_index :variants,  :inventory_id
  end

  def self.down
    remove_column :variants, :inventory_id
    add_column :variants, :count_on_hand, :integer
    add_column :variants, :count_pending_to_customer, :integer
    add_column :variants, :count_pending_from_supplier, :integer
  end
end
