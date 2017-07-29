class RenameShipmentsCountInOrders < ActiveRecord::Migration[4.2]
  def self.up
    rename_column :orders, :shipment_counter, :shipments_count
  end

  def self.down
    rename_column :orders, :shipments_count, :shipment_counter
  end
end
