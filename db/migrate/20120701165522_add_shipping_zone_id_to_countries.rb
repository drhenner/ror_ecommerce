class AddShippingZoneIdToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :shipping_zone_id, :integer
    add_index  :countries, :shipping_zone_id
  end
end
