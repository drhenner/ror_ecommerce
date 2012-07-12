class ChangeKeywordsToStringInProducts < ActiveRecord::Migration
  def up
    change_column :products, :product_keywords, :string, :limit => 255
  end

  def down
    change_column :products, :product_keywords, :text
  end
end
