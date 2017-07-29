class CreateSales < ActiveRecord::Migration[4.2]
  def change
    create_table :sales do |t|
      t.integer :product_id
      t.decimal :percent_off, :precision => 8, :scale => 2, :default => 0.0
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end

    add_index :sales, :product_id
  end
end
