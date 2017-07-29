class CreateCoupons < ActiveRecord::Migration[4.2]
  def self.up
    create_table :coupons do |t|
      t.string :type,                   :null => false
      t.string :code,                   :null => false
      t.decimal :amount,        :precision => 8, :scale => 2, :default => 0
      t.decimal :minimum_value, :precision => 8, :scale => 2
      t.integer :percent,   :default => 0
      t.text :description,              :null => false
      t.boolean :combine,   :default => false
      t.datetime :starts_at
      t.datetime :expires_at

      t.timestamps
    end

    add_index :coupons, :code
    add_index :coupons, :expires_at

  end

  def self.down
    drop_table :coupons
  end
end
