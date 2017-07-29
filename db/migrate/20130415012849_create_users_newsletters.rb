class CreateUsersNewsletters < ActiveRecord::Migration[4.2]
  def change
    create_table :users_newsletters do |t|
      t.integer :user_id
      t.integer :newsletter_id

      t.datetime :updated_at,   :null => false
    end
    add_index  :users_newsletters, :user_id
    add_index  :users_newsletters, :newsletter_id
  end
end
