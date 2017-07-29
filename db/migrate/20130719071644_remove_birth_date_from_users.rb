class RemoveBirthDateFromUsers < ActiveRecord::Migration[4.2]
  def up
    remove_column :users, :birth_date
  end

  def down
    add_column :users, :birth_date, :date
  end
end
