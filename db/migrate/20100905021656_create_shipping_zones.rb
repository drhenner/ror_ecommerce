class CreateShippingZones < ActiveRecord::Migration[4.2]
  def self.up
    create_table :shipping_zones do |t|
      t.string :name, :null => false

    end
  end

  def self.down
    drop_table :shipping_zones
  end
end
