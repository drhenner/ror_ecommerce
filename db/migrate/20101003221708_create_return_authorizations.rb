class CreateReturnAuthorizations < ActiveRecord::Migration[4.2]
  def self.up
    create_table :return_authorizations do |t|
      t.string :number#,         :null => false
      t.decimal :amount,          :precision => 8, :scale => 2, :null => false
      t.decimal :restocking_fee,  :precision => 8, :scale => 2,                 :default => 0
      t.integer :order_id,      :null => false
      t.integer :user_id,       :null => false
      t.string :state,          :null => false
      t.integer :created_by
      t.boolean :active,                                                        :default => true

      t.timestamps
    end
    add_index :return_authorizations, :number
    add_index :return_authorizations, :order_id
    add_index :return_authorizations, :user_id
    add_index :return_authorizations, :created_by
  end

  def self.down
    drop_table :return_authorizations
  end
end
