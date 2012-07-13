class AddCountryIdToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :country_id, :integer
    if !HADEAN_CONFIG['require_state_in_address']
      add_index  :addresses, :country_id
    end
  end
end
