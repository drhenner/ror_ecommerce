class CreateAddresses < ActiveRecord::Migration[4.2]
  def self.up
    create_table :addresses do |t|
      t.integer  :address_type_id
      t.string   "first_name"
      t.string   "last_name"
      t.string   'addressable_type',  :null => false
      t.integer  'addressable_id',    :null => false
      t.string   "address1",          :null => false
      t.string   "address2"
      t.string   "city",              :null => false
      t.integer  "state_id"
      t.string   "state_name"
      t.string   "zip_code",          :null => false
      t.integer   "phone_id"
      t.string   "alternative_phone"
      t.boolean  "default",             :default => false
      t.boolean  "billing_default",     :default => false
      t.boolean  'active',              :default => true
      t.timestamps
    end

    add_index :addresses, :state_id
    add_index :addresses, :addressable_id
    add_index :addresses, :addressable_type
    execute "alter table addresses add constraint fk_addresses_countries foreign key (state_id) references states(id)" if SETTINGS[:use_foreign_keys]
  end

  def self.down
    execute "alter table addresses drop foreign key fk_addresses_countries" if SETTINGS[:use_foreign_keys]
    drop_table :addresses
  end
end
