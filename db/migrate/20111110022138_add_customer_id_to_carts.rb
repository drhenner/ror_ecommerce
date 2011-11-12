class AddCustomerIdToCarts < ActiveRecord::Migration
  def change
    # This column is specifically for the admin cart
    add_column :carts, :customer_id, :integer
  end
end
