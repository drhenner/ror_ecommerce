class MoveBrandToProducts < ActiveRecord::Migration[4.2]
  def change
    remove_column :variants, :brand_id
  end
end
