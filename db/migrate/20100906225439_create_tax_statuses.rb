class TaxStatus < ActiveRecord::Base; end

class CreateTaxStatuses < ActiveRecord::Migration
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
