class CreateSuppliers < ActiveRecord::Migration[4.2]
  def self.up
    create_table :suppliers do |t|
      t.string      :name, :null => false
      t.string      :email

      t.timestamps
    end
  end

  def self.down
    drop_table :suppliers
  end
end
