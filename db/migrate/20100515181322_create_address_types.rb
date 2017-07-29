class CreateAddressTypes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :address_types do |t|
      t.string  :name,        :limit => 64, :null => false
      t.string  :description
    end
    add_index :address_types, :name
  end

  def self.down
    drop_table :address_types
  end
end
