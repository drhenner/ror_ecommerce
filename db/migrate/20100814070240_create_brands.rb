class CreateBrands < ActiveRecord::Migration[4.2]
  def self.up
    create_table :brands do |t|
      t.string      :name
    end
  end

  def self.down
    drop_table :brands
  end
end
