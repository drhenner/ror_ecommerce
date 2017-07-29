class AddBrandToProducts < ActiveRecord::Migration[4.2]

  def self.up
    add_column :products, :brand_id, :integer
    # Just in case someone is upgrading
    Product.reset_column_information
    Product.includes(:variants).all.each do |product|
      product.brand_id = product.variants.first.try(:brand_id)
      product.save
    end
    add_index :products, :brand_id
  end

  def self.down
    remove_column :products, :brand_id
  end
end
