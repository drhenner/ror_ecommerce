class CreatePhoneTypes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :phone_types do |t|
      t.string  :name,  :null => false
    end
  end

  def self.down
    drop_table :phone_types
  end
end
