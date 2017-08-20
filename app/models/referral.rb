class Referral < ApplicationRecord
  belongs_to :referring_user, :foreign_key => "referring_user_id", :class_name => "User"
  belongs_to :referral_user,  :foreign_key => "referral_user_id", :class_name => "User"
  belongs_to :referral_program
  belongs_to :referral_type

  validates :referral_program_id,         presence: true
  validates :referral_type_id,            presence: true
  validates :referring_user_id,            presence: true
  validates :email,             presence:   true,
                                uniqueness: true,
                                format:     { with: CustomValidators::Emails.email_validator }

  before_validation :assign_referral_program
  validate :validate_has_not_signed_up_yet

  after_create :invite_referral

  delegate :decimal_amount, to: :referral_program

  CHARACTERS_SEED = 20
  NUMBER_SEED     = 2001002

  attr_accessor :skip_validate_has_not_signed_up_yet

  def referral_code
    ((NUMBER_SEED + id) * 13).to_s(CHARACTERS_SEED)
  end

  ## determines the shipment id from the shipment.number
  #
  # @param [String]  represents the shipment.number
  # @return [Integer] id of the shipment to find
  def self.id_from_referral_code(num)
    ((num.to_i(CHARACTERS_SEED)) / 13) - NUMBER_SEED
  end

  ## finds the Shipment from the shipments number.  Is more optimal than the normal rails find by id
  #      because if calculates the shipment's id which is indexed
  #
  # @param [String]  represents the shipment.number
  # @return [Shipment]
  def self.find_by_referral_code(num)
    find(id_from_referral_code(num))##  now we can search by id which should be much faster
  end

  def email_link_followed?
    clicked_at?
  end

  def referral_user_name
    referral_user_id ? referral_user.name : 'N/A'
  end

  def registered?
    registered_at?
  end

  def purchased?
    purchased_at?
  end

  def display_status
    used? ? display_purchase_status : 'Not Signed up'
  end

  def display_purchase_status
    # purchased? ? 'Made a purchase.' : 'No Purchase'
    if purchased?
      "Purchased"
    elsif registered?
      "Registered"
    else
      "Signed up"
    end
  end

  def display_formatted_status_date(format = :us_date)
    I18n.localize(display_status_date, :format => format)
  end
  def display_status_date
    if !used?
      created_at
    elsif purchased?
      purchased_at
    elsif registered?
      registered_at
    else
      referral_user.created_at
    end
  end

  def used?
    referral_user_id?
  end

  def give_credits!
    if referring_user && purchased? && !applied
      referral_program.give_credits(referring_user)
      self.applied = true
      self.skip_validate_has_not_signed_up_yet = true
      save!
      Notifier.new_referral_credits(referring_user.id, referral_user.id).deliver rescue true
    end
  end

  def set_referral_user(user_id)
    self.referral_user_id = user_id
    self.registered_at    = Time.zone.now
    self.skip_validate_has_not_signed_up_yet = true
    self.save
  end

  def self.unapplied
    where(:applied => false)
  end

  def self.purchased
    where("purchased_at IS NOT NULL")
  end

  def self.not_purchased
    where(:purchased_at => nil)
  end
  private
    def invite_referral
      Notifier.referral_invite(self.id, referring_user_id).deliver_later
    end

    def validate_has_not_signed_up_yet
      unless skip_validate_has_not_signed_up_yet == true
        self.errors.add(:base, 'This user has already signed up.') if has_signed_up
      end
      true
    end
    def has_signed_up
      (User.where(:email => email).limit(1).count != 0)
    end

    def assign_referral_program
      self.referral_program_id ||= ReferralProgram.current_program.id
    end
end
