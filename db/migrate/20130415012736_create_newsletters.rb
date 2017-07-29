class CreateNewsletters < ActiveRecord::Migration[4.2]
  def change
    create_table :newsletters do |t|
      t.string :name, :null => false
      t.boolean :autosubscribe, :null => false

    end
  end
end
