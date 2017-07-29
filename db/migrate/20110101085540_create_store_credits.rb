class CreateStoreCredits < ActiveRecord::Migration[4.2]
  def self.up
    create_table :store_credits do |t|
      t.decimal :amount,  :default => 0.0,      :precision => 8, :scale => 2
      t.integer :user_id, :null => false
      t.timestamps
    end

    add_index :store_credits, :user_id
  end

  def self.down
    drop_table :store_credits
  end
end
