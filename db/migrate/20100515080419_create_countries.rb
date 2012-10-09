class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string :name
      t.string :abbreviation, :limit => 5
      t.integer :shipping_zone_id
    end
    add_index :countries, :name
    if SETTINGS[:use_foreign_keys]
      execute "alter table states add constraint fk_states_countries foreign key (country_id) references countries(id)"
    end
  end

  def self.down
    execute "alter table states drop foreign key fk_states_countries" if SETTINGS[:use_foreign_keys]
    drop_table :countries
  end
end
