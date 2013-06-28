class AddImageGroupIdToVariants < ActiveRecord::Migration
  def change
    add_column :variants, :image_group_id, :integer
  end
end
