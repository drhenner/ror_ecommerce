class CreateTaxRates < ActiveRecord::Migration[4.2]
  def self.up
    create_table :tax_rates do |t|
      t.decimal :percentage,      :null => false, :precision => 8, :scale => 2, :default => 0.0
      t.integer :state_id
      t.integer :country_id
      t.date :start_date,         :null => false
      t.date :end_date
      t.boolean :active, :default => true

      #t.timestamps
    end
    add_index :tax_rates, :state_id

  end

  def self.down
    drop_table :tax_rates
  end
end
