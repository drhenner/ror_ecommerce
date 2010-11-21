class Country < ActiveRecord::Base
  
  has_many :states
  
  validates :name,  :presence => true
  validates :abbreviation,  :presence => true
  
  USA_ID    = 214
  CANADA_ID = 35
  
  def abbreviation_name(append_name = "")
    ([abbreviation, name].join(" - ") + " #{append_name}").strip
  end

  def abbrev_and_name
    abbreviation_name
  end
  
  # Finds all the countries for a form select .
  #
  # @param none
  # @return [Array] an array of arrays with [string, country.id]
  def self.form_selector
    find(:all, :order => 'abbreviation ASC').collect { |c| [c.abbrev_and_name, c.id] }
  end
end
