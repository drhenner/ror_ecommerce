class AddTotalCostToPurchaseOrders < ActiveRecord::Migration[4.2]
  def self.up
    add_column :purchase_orders, :total_cost, :decimal, :null => false, :default => 0.0, :precision => 8, :scale => 2
  end

  def self.down
    remove_column :purchase_orders, :total_cost
  end
end
