class CreateReferrals < ActiveRecord::Migration[4.2]
  def change
    create_table :referrals do |t|
      t.boolean :applied,             :default => false
      t.datetime :clicked_at
      t.string :email,                :null => false
      t.string :name
      t.datetime :purchased_at
      t.integer :referral_program_id, :null => false
      t.integer :referral_type_id,    :null => false
      t.integer :referral_user_id
      t.integer :referring_user_id,   :null => false
      t.datetime :registered_at
      t.datetime :sent_at

      t.timestamps
    end
    add_index :referrals, :email, :length => 6
    add_index :referrals, :referral_program_id
    add_index :referrals, :referral_type_id
    add_index :referrals, :referral_user_id
    add_index :referrals, :referring_user_id
  end
end
