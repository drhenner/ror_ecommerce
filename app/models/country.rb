class Country < ActiveRecord::Base

  has_many  :states
  has_many  :countries
  belongs_to :shipping_zone

  validates :name,  :presence => true,       :length => { :maximum => 200 }
  validates :abbreviation,  :presence => true,       :length => { :maximum => 10 }

  scope :active, where(:active => true)

  # Call this method to display the country_abbreviation - country with and appending name
  #
  # @example abbreviation == USA, country == 'United States'
  #   country.abbreviation_name(': capitalist') => 'USA - United States : capitalist'
  #
  # @param [append name, optional]
  # @return [String] country abbreviation - country name
  def abbreviation_name(append_name = "")
    ([abbreviation, name].join(" - ") + " #{append_name}").strip
  end

  # Call this method to display the country_abbreviation - country
  #
  # @example abbreviation == USA, country == 'United States'
  #   country.abbrev_and_name => 'USA - United States'
  #
  # @param none
  # @return [String] country abbreviation - country name
  def abbrev_and_name
    abbreviation_name
  end

  # Finds all the countries for a form select .
  #
  # @param none
  # @return [Array] an array of arrays with [string, country.id]
  def self.form_selector
    active.order('abbreviation ASC').collect { |c| [c.abbrev_and_name, c.id] }
  end

  def shipping_zone_name
    Rails.cache.fetch("Country-shipping_zone_name-#{shipping_zone_id}", :expires_in => 1.days) do
      shipping_zone_id ? shipping_zone.name : '---'
    end
  end
end
