class CreateTransactions < ActiveRecord::Migration[4.2]
  def self.up
    create_table :transactions do |t|
      t.string :type
      t.integer :batch_id

      t.timestamps
    end
    add_index :transactions, :batch_id
  end

  def self.down
    drop_table :transactions
  end
end
