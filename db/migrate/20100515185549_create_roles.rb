class CreateRoles < ActiveRecord::Migration[4.2]
  def self.up
    create_table :roles do |t|
      t.string :name, :limit => 30, :null => false,   :unique => true
    end
    add_index :roles, :name
  end

  def self.down
    drop_table :roles
  end
end
