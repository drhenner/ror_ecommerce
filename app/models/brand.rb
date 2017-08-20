# The BRANDS table represents...  BRANDS!!!
#
# For now Brand is just a label added to some descriptive fields.  The only field is Name
# and hence the variants should use a method called brand_name and cache the result and hence one less DB query for this name.

# == Schema Information
#
# Table name: brands
#
#  id   :integer          not null, primary key
#  name :string(255)
#

class Brand < ApplicationRecord

  has_many :variants
  has_many :products

  validates :name,  presence: true,       length: { maximum: 255 }, uniqueness: true
                    #:format   => { :with => CustomValidators::Names.name_validator }
end
