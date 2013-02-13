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

class TaxRate < ActiveRecord::Base
  belongs_to :state
  belongs_to :country

  validates :percentage,    :numericality => true,
                            :presence => true
  validates :state_id,      :presence => true, :if => :tax_per_state?
  validates :country_id,    :presence => true, :if => :tax_per_country?
  validates :start_date,    :presence => true

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
    where(["tax_rates.start_date <= ? AND
           (end_date > ? OR end_date IS NULL)", time.to_date.to_s(:db), time.to_date.to_s(:db)])
  end

  # region_id can be state or country depending on the setup in config/settings.yml
  def self.for_region(region_id)
    where(["#{ Settings.tax_per_state_id ? 'state_id' : 'country_id'} = ?", region_id ])
  end

  private

    def tax_per_state?
      Settings.tax_per_state_id
    end

    def tax_per_country?
      !tax_per_state?
    end
end
