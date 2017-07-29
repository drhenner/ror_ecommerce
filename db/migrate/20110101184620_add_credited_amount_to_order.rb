class AddCreditedAmountToOrder < ActiveRecord::Migration[4.2]
  def self.up
    add_column :orders, :credited_amount, :decimal,  :default => 0.0,      :precision => 8, :scale => 2
  end

  def self.down
    remove_column :orders, :credited_amount
  end
end
