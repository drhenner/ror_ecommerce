# == Schema Information
#
# Table name: payment_profiles
#
#  id             :integer(4)      not null, primary key
#  user_id        :integer(4)
#  address_id     :integer(4)
#  payment_cim_id :string(255)
#  default        :boolean(1)
#  active         :boolean(1)
#  created_at     :datetime
#  updated_at     :datetime
#  last_digits    :string(255)
#  month          :string(255)
#  year           :string(255)
#  cc_type        :string(255)
#  first_name     :string(255)
#  last_name      :string(255)
#  card_name      :string(255)
#

##  NOTE  Payment profile methods have been created however these methods have not been tested in any fashion
#   These method are here to give you a heads start.  Once CIM is created these methods will be ready for use.
#
# => Please refer to the following web page about seting up CIM.  This code has not been fully tested but
#     should serve you very well.
# http://cookingandcoding.com/2010/01/14/using-activemerchant-with-authorize-net-and-authorize-cim/
#
require "active_merchant/billing/rails"

class PaymentProfile < ApplicationRecord
  include PaymentProfileCim
  belongs_to :user
  belongs_to :address

  attr_accessor       :request_ip, :credit_card

  validates :user_id,         presence: true
  validates :payment_cim_id,  presence: true
  validates :cc_type,         presence: true, length: { maximum: 60 }
  validates :last_digits,     presence: true, length: { maximum: 10 }
  validates :month,           presence: true, length: { maximum: 6 }
  validates :year,            presence: true, length: { maximum: 6 }


  validate            :validate_card
  #validates :address_id,      presence: true

  #attr_accessible # none

  def name
    [cc_type, last_digits].join(' - ')
  end

  def inactivate!
    self.active = false
    self.save!
  end

  # Use this method to create a PaymentProfile
  # => This method will create a new PaymentProfile and if the PaymentProfile is a default PaymentProfile it
  # => will make all other PaymentProfiles that belong to the user non-default
  #
  # @param [User] user associated to the payment profile
  # @param [Hash] hash of attributes for the new address
  # @ return [Boolean] true or nil
  def save_default_profile(cc_user)
    PaymentProfile.transaction do
      if self.default == true
        PaymentProfile.update_all( { default: false },
                            { payment_profiles: {
                                  user_id: cc_user.id,
                                            } }) if cc_user
      end
      self.user = cc_user
      self.save
    end
  end
  # method used by forms to credit a temp credit card
  #
  # ------------
  # behave like it's
  #   has_one :credit_card
  #   accepts_nested_attributes_for :credit_card_info
  #
  # @param [none]
  # @return [CreditCard]
  def credit_card_info=( card_or_params )
    self.credit_card = case card_or_params
      when ActiveMerchant::Billing::CreditCard, nil
        card_or_params
      else
        ActiveMerchant::Billing::CreditCard.new(card_or_params)
      end
    set_minimal_cc_data(self.credit_card)
  end

  # credit card object with known values
  #
  # @param [none]
  # @return [CreditCard]
  def new_credit_card
    # populate new card with some saved values
    ActiveMerchant::Billing::CreditCard.new(
      :first_name  => user.first_name,
      :last_name   => user.last_name,
      # :address etc too if we have it
      :brand        => cc_type
    )
  end

  # -------------
  private

  def set_minimal_cc_data(card)
    self.last_digits  = card.last_digits
    self.month        = card.month
    self.year         = card.year
    self.first_name   = card.first_name.strip   if card.first_name?
    self.last_name    = card.last_name.strip    if card.last_name?
    self.cc_type      = card.brand
  end

  def validate_card
    return true if !self.active
    if credit_card.nil?
      errors.add( :base, 'Credit Card is not present.')
      return false
    end
    # first validate via ActiveMerchant local code
    unless credit_card.valid?
      # collect credit card error messages into the profile object
      #errors.add(:credit_card, "must be valid")
      credit_card.errors.full_messages.each do |message|
        errors.add(:base, message)
      end
      return
    end

    true
  end

end
