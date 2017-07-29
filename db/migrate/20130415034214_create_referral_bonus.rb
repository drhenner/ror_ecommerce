class CreateReferralBonus < ActiveRecord::Migration[4.2]
  def change
    create_table :referral_bonuses do |t|
      t.integer :amount,  :null => false
      t.string :name,     :null => false

      t.timestamps
    end
  end
end
