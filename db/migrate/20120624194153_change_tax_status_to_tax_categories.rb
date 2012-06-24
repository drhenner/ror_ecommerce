class TaxStatus < ActiveRecord::Base; end

class ChangeTaxStatusToTaxCategories < ActiveRecord::Migration
  def up
    #rename table to tax_category
    rename_table :tax_statuses, :tax_categories

    #rename tax_status_id to tax_category_id
    #TaxRate
    rename_column :tax_rates, :tax_status_id, :tax_category_id
    #Product
    remove_column(:products, :tax_category_id)
    rename_column :products, :tax_status_id, :tax_category_id
  end

  def down
    #rename table to tax_category
    rename_table  :tax_categories, :tax_statuses

    #rename tax_status_id to tax_category_id
    #TaxRate
    rename_column :tax_rates, :tax_category_id, :tax_status_id
    #Product
    rename_column :products, :tax_category_id, :tax_status_id
  end
end
