class CreatePaymentProfiles < ActiveRecord::Migration[4.2]
  def self.up
    create_table :payment_profiles do |t|
      t.integer :user_id
      t.integer :address_id
      t.string :payment_cim_id
      t.boolean :default
      t.boolean :active

      t.timestamps
    end
      add_index :payment_profiles, :user_id
      add_index :payment_profiles, :address_id
      #add_index :payment_profiles, :payment_cim_id
  end

  def self.down
    drop_table :payment_profiles
  end
end
