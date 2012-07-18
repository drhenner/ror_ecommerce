class AddActiveToCountry < ActiveRecord::Migration
  def change
    add_column :countries, :active, :boolean, :null => false, :default => false
    Country.reset_column_information
    usa = Country.find_by_id(Country::USA_ID)
    if usa # this means they are upgrading their local copy
      usa.active = true
      usa.save # lets make USA active so people don't have to configure to see things working
    end
    canada = Country.find_by_id(Country::CANADA_ID)
    if canada # this means they are upgrading their local copy
      canada.active = true
      canada.save # lets make CANADA active so people don't have to configure to see things working
    end
    add_index  :addresses, :active  # we will search for active almost every time.  normally I don't do this for a boolean
  end
end
