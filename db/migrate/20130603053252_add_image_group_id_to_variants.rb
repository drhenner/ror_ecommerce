class AddImageGroupIdToVariants < ActiveRecord::Migration[4.2]
  def change
    add_column :variants, :image_group_id, :integer
  end
end
