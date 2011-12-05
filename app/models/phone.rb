# == Schema Information
#
# Table name: phones
#
#  id             :integer(4)      not null, primary key
#  phone_type_id  :integer(4)
#  number         :string(255)     not null
#  phoneable_type :string(255)     not null
#  phoneable_id   :integer(4)      not null
#  primary        :boolean(1)      default(FALSE)
#  created_at     :datetime
#  updated_at     :datetime
#

class Phone < ActiveRecord::Base

  belongs_to :phone_type
  #belongs_to :phone_priority
  belongs_to :phoneable, :polymorphic => true

  validates :number,  :presence => true,
                      :format   => { :with => CustomValidators::Numbers.phone_number_validator },
                      :length   => { :maximum => 255 }


  # Use this method to create a phone
  # * This method will create a new phone object and if the phone is a default phone it
  # * will make all other phones that belong to the user non-default
  #
  # @param [object] object associated to the phone (user or possibly a company in the future)
  # @param [Hash] hash of attributes for the new phone
  # @ return [Boolean] true or nil
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
