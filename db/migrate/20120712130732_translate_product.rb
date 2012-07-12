class TranslateProduct < ActiveRecord::Migration
  def up
    Product.create_translation_table!({
        :name => :string,
        :description => :text,
        :product_keywords => :text,
        :meta_keywords => :string,
        :meta_description => :string,
        :description_markup => :text
    }, {:migrate_data => true})
  end

  def down
    Product.drop_translation_table! :migrate_data => true
  end
end
