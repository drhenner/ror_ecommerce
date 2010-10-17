class PrototypeProperty < ActiveRecord::Base
  
  belongs_to :prototype
  belongs_to :property
  
  validates :prototype_id,    :presence => true
  validates :property_id,    :presence => true
end
