class CreateComments < ActiveRecord::Migration[4.2]
  def self.up
    create_table :comments do |t|
      t.text :note
      t.string :commentable_type
      t.integer :commentable_id
      t.integer :created_by
      t.integer :user_id

      t.timestamps
    end

    add_index :comments, :commentable_type
    add_index :comments, :commentable_id
    add_index :comments, :created_by
    add_index :comments, :user_id

  end

  def self.down
    drop_table :comments
  end
end
