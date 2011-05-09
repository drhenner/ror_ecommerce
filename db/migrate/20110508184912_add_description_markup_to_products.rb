class AddDescriptionMarkupToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :description_markup, :text
  end

  def self.down
    remove_column :products, :description_markup
  end
end
