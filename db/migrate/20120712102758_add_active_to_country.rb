class AddActiveToCountry < ActiveRecord::Migration
  def change
    add_column :countries, :active, :boolean, :null => false, :default => false
  end
end
