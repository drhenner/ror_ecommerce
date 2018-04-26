class ReferralProgram < ApplicationRecord
  has_many :referrals
  belongs_to :referral_bonus

  validates :name,        presence: true,       length: { maximum: 40 }
  validates :description, presence: true,       length: { maximum: 600 }
  validates :referral_bonus_id, presence: true

  delegate :decimal_amount, :to => :referral_bonus

  PROGRAMS = [
      { :name         => '$5 per Referral',
        :description  => "For every referral that joins #{I18n.t(:company)} and makes a purchase.  $5 will be given to you as store credit.",
        :referral_bonus_id => 1
      }
    ]
  TEN_DOLLAR_BONUS_ID = 1

  before_save :sanitize

  def self.current_program
    active.first
  end

  def self.active
    where(:active => true)
  end

  def give_credits(user)
    referral_bonus.give_credits(user)
  end

  private

    def sanitize
      self.active = true if active.nil? # only allow true or false
    end

end
