class CreateReturnReasons < ActiveRecord::Migration[4.2]
  def self.up
    create_table :return_reasons do |t|
      t.string :label
      t.string :description

    end
  end

  def self.down
    drop_table :return_reasons
  end
end
