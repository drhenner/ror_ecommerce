class CreatePhones < ActiveRecord::Migration[4.2]
  def self.up
    create_table :phones do |t|
      t.integer  :phone_type_id
      t.string   "number",          :null => false
      t.string   'phoneable_type',  :null => false
      t.integer  'phoneable_id',    :null => false
      t.boolean  "primary",         :default => false
      t.timestamps
    end

    add_index :phones, :phoneable_type
    add_index :phones, :phoneable_id
    add_index :phones, :phone_type_id
  end

  def self.down
    drop_table :phones
  end
end
