class AddDescriptionMarkupToProducts < ActiveRecord::Migration[4.2]
  def self.up
    add_column :products, :description_markup, :text
  end

  def self.down
    remove_column :products, :description_markup
  end
end
