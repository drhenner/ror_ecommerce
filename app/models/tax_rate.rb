# == Schema Information
#
# Table name: tax_rates
#
#  id            :integer(4)      not null, primary key
#  percentage    :decimal(8, 2)   default(0.0), not null
#  state_id      :integer(4)      not null
#  country_id      :integer(4)      not null
#  start_date    :date            not null
#  end_date      :date
#  active        :boolean(1)      default(TRUE)
#

class TaxRate < ApplicationRecord
  belongs_to :state
  belongs_to :country

  validates :percentage,    numericality: true,
                            presence: true
  validates :state_id,      presence: true, if: :tax_per_state?
  validates :country_id,    presence: true, if: :tax_per_country?
  validates :start_date,    presence: true

  after_save :expire_cache

  def tax_percentage
    Settings.vat ? 0.0 : percentage
  end

  def vat_percentage
    Settings.vat ? percentage : 0.0
  end

  def self.active
    where(["tax_rates.active = ?", true])
  end

  def inactivate!
    self.update_attributes(:active => false)
  end

  def self.at(time = Time.zone.now)
    where(:tax_rates => {:id => TaxRate.active_at_ids(time.to_date)})
  end

  # region_id can be state or country depending on the setup in config/settings.yml
  def self.for_region(region_id)
    where(["#{ Settings.tax_per_state_id ? 'state_id' : 'country_id'} = ?", region_id ])
  end

  def self.active_at_ids(date = Time.zone.now.to_date)
    #Rails.cache.fetch("TaxRate-#{I18n.t(:company)}-active_at_ids-#{date}", :expires_in => 23.hours) do
      TaxRate.where(["tax_rates.start_date <= ? AND
             (end_date > ? OR end_date IS NULL)", date.to_s(:db), date.to_s(:db)]).pluck(:id)
    #end
  end

  private

    def expire_cache
      Rails.cache.delete("TaxRate-#{I18n.t(:company)}-active_at_ids-#{Date.yesterday}")
      Rails.cache.delete("TaxRate-#{I18n.t(:company)}-active_at_ids-#{Date.today}")
      Rails.cache.delete("TaxRate-#{I18n.t(:company)}-active_at_ids-#{Date.tomorrow}")
    end

    def tax_per_state?
      Settings.tax_per_state_id
    end

    def tax_per_country?
      !tax_per_state?
    end
end
