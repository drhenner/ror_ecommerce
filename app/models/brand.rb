class Brand < ActiveRecord::Base
  
  has_many :variants
  
  validates :name,  :presence => true#,
                    #:format   => { :with => CustomValidators::Names.name_validator }
end
