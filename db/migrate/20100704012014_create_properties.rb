class CreateProperties < ActiveRecord::Migration[4.2]
  def self.up
    create_table :properties do |t|
      t.string      :identifing_name, :null => false
      t.string      :display_name
      t.boolean     :active,          :default => true
    end
  end

  def self.down
    drop_table :properties
  end
end
