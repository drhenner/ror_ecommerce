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

class Phone < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  belongs_to :phone_type
  belongs_to :phoneable, polymorphic: true

  validates :phone_type_id, presence: true
  validates :number,  presence: true, numericality: { only_integer: true },
                     # :format   => { :with => CustomValidators::Numbers.phone_number_validator },
                      length:    { maximum: 25 }

  before_validation :sanitize_data
  after_save        :default_phone_check

  def display_number=(val)
    self.number = val
  end

  def display_number
    number_to_phone( self.number )
  end
  private

    def default_phone_check
        Phone.update_all(["phones.primary = ?", false],
                          ["phones.phoneable_id = ? AND phones.phoneable_type = ? AND id <> ?",
                            phoneable_id, phoneable_type, id]) if self.primary
    end

    def sanitize_data
      #  remove non-digits
      self.number = self.number.gsub!(/\W+/, '') if number
    end

end
