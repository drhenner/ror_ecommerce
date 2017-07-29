class CreateTransactionLedgers < ActiveRecord::Migration[4.2]
  def self.up
    create_table :transaction_ledgers do |t|
      t.string :accountable_type
      t.integer :accountable_id
      t.integer :transaction_id
      t.integer :transaction_account_id
      t.decimal :tax_amount, :precision => 8, :scale => 2,  :default => 0.0
      t.decimal :debit,      :precision => 8, :scale => 2,  :null => false
      t.decimal :credit,      :precision => 8, :scale => 2, :null => false
      t.string :period

      t.timestamps
    end
    add_index :transaction_ledgers, :accountable_id
    add_index :transaction_ledgers, :transaction_id
    add_index :transaction_ledgers, :transaction_account_id
  end

  def self.down
    drop_table :transaction_ledgers
  end
end
