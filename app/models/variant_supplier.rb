# == Schema Information
#
# Table name: variant_suppliers
#
#  id                      :integer(4)      not null, primary key
#  variant_id              :integer(4)      not null
#  supplier_id             :integer(4)      not null
#  cost                    :decimal(8, 2)   default(0.0), not null
#  total_quantity_supplied :integer(4)      default(0)
#  min_quantity            :integer(4)      default(1)
#  max_quantity            :integer(4)      default(10000)
#  active                  :boolean(1)      default(TRUE)
#  created_at              :datetime
#  updated_at              :datetime
#

class VariantSupplier < ApplicationRecord

  belongs_to :supplier
  belongs_to :variant

  validates :variant_id,  presence: true
  validates :supplier_id, presence: true
  validates :cost,        presence: true
end
