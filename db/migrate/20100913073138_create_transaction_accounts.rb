class CreateTransactionAccounts < ActiveRecord::Migration
  def self.up
    create_table :transaction_accounts do |t|
     # t.string :type
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :transaction_accounts
  end
end
