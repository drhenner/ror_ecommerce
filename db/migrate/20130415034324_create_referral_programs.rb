class CreateReferralPrograms < ActiveRecord::Migration[4.2]
  def change
    create_table :referral_programs do |t|
      t.boolean :active,  :null => false
      t.text :description
      t.string :name,               :null => false
      t.integer :referral_bonus_id, :null => false

      t.timestamps
    end
    add_index :referral_programs, :referral_bonus_id
  end
end
