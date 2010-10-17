class Phone < ActiveRecord::Base
  
  belongs_to :phone_type
  #belongs_to :phone_priority
  belongs_to :phoneable, :polymorphic => true
  
  validates :number,  :presence => true, 
                      :format   => { :with => CustomValidators::Numbers.phone_number_validator }
  
  
  def save_default_phone(object, params)
    Phone.transaction do
      if params[:default] && params[:default] != '0'
        Address.update_all(["phones.primary = ?", false], 
                            ["phones.phoneable_id = ? AND phones.phoneable_type = ? ", object.id, object.class.to_s]) if object
        self.default = true
      end
      self.phoneable = object
      self.save

    end
  end
end
