class MoveBrandToProducts < ActiveRecord::Migration
  def change
    remove_column :variants, :brand_id
  end
end
