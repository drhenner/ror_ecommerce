class AddTotalCostToPurchaseOrders < ActiveRecord::Migration
  def self.up
    add_column :purchase_orders, :total_cost, :decimal, :null => false, :precision => 8, :scale => 2
  end

  def self.down
    remove_column :purchase_orders, :total_cost
  end
end
