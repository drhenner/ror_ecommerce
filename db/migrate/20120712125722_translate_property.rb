class TranslateProperty < ActiveRecord::Migration
  def up
    Property.create_translation_table!({:display_name => :string}, {:migrate_data => true})
  end

  def down
    Property.drop_translation_table! :migrate_data => true
  end
end
