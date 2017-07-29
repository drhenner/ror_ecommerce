class TaxStatus < ActiveRecord::Base; end

class CreateTaxStatuses < ActiveRecord::Migration[4.2]
  def self.up
    create_table :tax_statuses do |t|
      t.string :name, :null => false

      #t.timestamps
    end
  end

  def self.down
    drop_table :tax_statuses
  end
end
