class RemoveBirthDateFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :birth_date
  end

  def down
    add_column :users, :birth_date, :date
  end
end
