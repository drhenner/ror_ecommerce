class CreatePrototypes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :prototypes do |t|
      t.string      :name, :null => false
      t.boolean     :active, :null => false, :default => true
    end
  end

  def self.down
    drop_table :prototypes
  end
end
