class CreatePayments < ActiveRecord::Migration[4.2]
  def self.up
    create_table :payments do |t|
      t.integer :invoice_id
      t.string :confirmation_id
      t.integer :amount
      t.string :error
      t.string :error_code
      t.string :message
      t.string :action
      t.text    :params
      t.boolean :success
      t.boolean :test

      t.timestamps
    end
    add_index :payments, :invoice_id
  end

  def self.down
    drop_table :payments
  end
end
