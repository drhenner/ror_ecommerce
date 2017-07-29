class CreateStates < ActiveRecord::Migration[4.2]
  def self.up
    create_table :states do |t|

      t.string :name,                       :null => false
      t.string :abbreviation, :limit => 5,  :null => false,   :unique => true
      t.string :described_as
      t.integer :country_id,                :null => false
      t.integer :shipping_zone_id,          :null => false
    end
    add_index :states, :name
    add_index :states, :country_id
    add_index :states, :abbreviation
  end

  def self.down
    drop_table :states
  end
end
