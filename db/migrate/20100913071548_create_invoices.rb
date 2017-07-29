class CreateInvoices < ActiveRecord::Migration[4.2]
  def self.up
    create_table :invoices do |t|
      t.integer   :order_id,      :null => false
      #t.string    :number,        :null => false
      t.decimal   :amount,        :null => false,             :precision => 8, :scale => 2
      #t.boolean :settled,     :default => false,  :null => false
      t.string    :invoice_type,  :null => false, :default => Invoice::PURCHASE
      t.string    :state,         :null => false
      t.boolean   :active,        :null => false, :default => true

      t.timestamps
    end
      #add_index :invoices, :number
    add_index :invoices, :order_id
  end

  def self.down
    drop_table :invoices
  end
end
