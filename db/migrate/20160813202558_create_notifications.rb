class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.integer  :user_id
      t.string   :type,            null: false
      t.integer  :notifiable_id,   null: false
      t.string   :notifiable_type, null: false
      t.datetime :send_at
      t.datetime :sent_at

      t.datetime :created_at,      null: false
    end
    add_index :notifications, [:type, :user_id]
    add_index :notifications, [:user_id]
    add_index :notifications, [:notifiable_type, :notifiable_id]
  end
end
