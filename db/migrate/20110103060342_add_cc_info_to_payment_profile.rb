class AddCcInfoToPaymentProfile < ActiveRecord::Migration[4.2]
  def self.up
    add_column :payment_profiles, :last_digits, :string,  :length => 8
    add_column :payment_profiles, :month,       :string,  :length => 20
    add_column :payment_profiles, :year,        :string,  :length => 8
    add_column :payment_profiles, :cc_type,      :string,  :length => 30
    add_column :payment_profiles, :first_name,   :string,  :length => 30
    add_column :payment_profiles, :last_name,    :string,  :length => 30
    add_column :payment_profiles, :card_name,    :string,  :length => 120
  end

  def self.down
    remove_column :payment_profiles, :last_digits
    remove_column :payment_profiles, :month
    remove_column :payment_profiles, :year
    remove_column :payment_profiles, :cc_type
    remove_column :payment_profiles, :first_name
    remove_column :payment_profiles, :last_name
    remove_column :payment_profiles, :card_name
  end
end
