class CreateAccounts < ActiveRecord::Migration[4.2]
  def self.up
    create_table :accounts do |t|
      t.string  :name,            :null => false
      t.string  :account_type,    :null => false
      t.decimal :monthly_charge,  :null => false, :default => 0.0, :precision => 8, :scale => 2
      t.boolean :active,          :null => false, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
