class CreateAccountingAdjustments < ActiveRecord::Migration[4.2]
  def change
    create_table :accounting_adjustments do |t|
      t.integer :adjustable_id,  :null => false
      t.string :adjustable_type,  :null => false
      t.string :notes
      t.decimal :amount,      :precision => 8, :scale => 2,  :null => false

      t.timestamps
    end
    add_index :accounting_adjustments, :adjustable_id
  end
end
