class AddCreditedAmountToInvoice < ActiveRecord::Migration
  def self.up
    add_column :invoices, :credited_amount, :decimal,  :default => 0.0,      :precision => 8, :scale => 2
  end

  def self.down
    remove_column :invoices, :credited_amount
  end
end
