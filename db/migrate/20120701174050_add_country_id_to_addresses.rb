class AddCountryIdToAddresses < ActiveRecord::Migration[4.2]
  def change
    add_column :addresses, :country_id, :integer
    if !Settings.require_state_in_address
      add_index  :addresses, :country_id
    end
  end
end
