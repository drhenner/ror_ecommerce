class CreateShippingRateTypes < ActiveRecord::Migration
  def self.up
    create_table :shipping_rate_types do |t|
      t.string :name, :null => false

    end
  end

  def self.down
    drop_table :shipping_rate_types
  end
end
