class Brand < ActiveRecord::Base

  has_many :variants
  has_many :products

  validates :name,  :presence => true,       :length => { :maximum => 255 }, :uniqueness => true
                    #:format   => { :with => CustomValidators::Names.name_validator }
end
