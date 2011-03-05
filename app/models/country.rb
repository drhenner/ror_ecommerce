class Country < ActiveRecord::Base

  has_many :states

  validates :name,  :presence => true,       :length => { :maximum => 200 }
  validates :abbreviation,  :presence => true,       :length => { :maximum => 10 }

  USA_ID    = 214
  CANADA_ID = 35

  ACTIVE_COUNTRY_IDS = [CANADA_ID, USA_ID]

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
    find(ACTIVE_COUNTRY_IDS, :order => 'abbreviation ASC').collect { |c| [c.abbrev_and_name, c.id] }
  end
end
