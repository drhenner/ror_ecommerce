class CreateBatches < ActiveRecord::Migration[4.2]
  def self.up
    create_table :batches do |t|
      t.string :batchable_type
      t.integer :batchable_id
      t.string :name

      t.timestamps
    end
    add_index :batches, :batchable_type
    add_index :batches, :batchable_id
  end

  def self.down
    drop_table :batches
  end
end
