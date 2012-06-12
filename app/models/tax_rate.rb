# == Schema Information
#
# Table name: tax_rates
#
#  id            :integer(4)      not null, primary key
#  percentage    :decimal(8, 2)   default(0.0), not null
#  tax_status_id :integer(4)      not null
#  state_id      :integer(4)      not null
#  start_date    :date            not null
#  end_date      :date
#  active        :boolean(1)      default(TRUE)
#

class TaxRate < ActiveRecord::Base
  belongs_to :state
  belongs_to :tax_status

  validates :percentage,    :numericality => true,
                            :presence => true
  validates :tax_status_id, :presence => true
  validates :state_id,      :presence => true
  validates :start_date,    :presence => true

  delegate :country, :to => :state

  def country=(value)
  end

  def tax_percentage
    GlobalConstants::VAT_TAX_SYSTEM ? 0.0 : percentage
  end

  def vat_percentage
    GlobalConstants::VAT_TAX_SYSTEM ? percentage : 0.0
  end
end
