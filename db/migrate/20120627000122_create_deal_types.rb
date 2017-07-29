class CreateDealTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :deal_types do |t|
      t.string :name, :null => false

      t.timestamps
    end
  end
end
