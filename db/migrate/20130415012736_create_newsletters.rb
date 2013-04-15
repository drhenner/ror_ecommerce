class CreateNewsletters < ActiveRecord::Migration
  def change
    create_table :newsletters do |t|
      t.string :name, :null => false
      t.boolean :autosubscribe, :null => false

    end
  end
end
