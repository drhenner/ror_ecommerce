class VariantSupplier < ActiveRecord::Base
  
  belongs_to :supplier
  belongs_to :variant
    
  validates :variant_id,  :presence => true  
  validates :supplier_id, :presence => true
  validates :cost,        :presence => true
end
