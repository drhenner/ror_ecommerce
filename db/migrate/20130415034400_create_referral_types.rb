class CreateReferralTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :referral_types do |t|
      t.string :name, :null => false
    end
  end
end
