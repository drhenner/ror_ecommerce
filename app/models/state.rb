# States are "states, territories and provinces" of a country. This table is seeded from
#   the db/seeds.rb file.  The seed data is supplied by db/seed/international_states/*.yml files.
#
#  If you need to seed a state other than a state in the United states You should watch the following video:
#
#  http://www.ror-e.com/info/videos/2
#

class State < ApplicationRecord

  belongs_to :country
  has_many   :addresses
  has_many   :tax_rates
  belongs_to :shipping_zone

  validates :name,              presence: true, length: { maximum: 150 }
  validates :abbreviation,      presence: true, length: { maximum: 12 }
  validates :country_id,        presence: true
  validates :shipping_zone_id,  presence: true

  # the abbreviation and name of the state separated by '-' and optionally appended by characters
  #
  # @param [none]
  # @return [ String ]
  def abbreviation_name(append_name = "")
    ([abbreviation, name].join(" - ") + " #{append_name}").strip
  end

  # the abbreviation and name of the state separated by '-'
  #
  # @param [none]
  # @return [ String ]
  def abbrev_and_name
    abbreviation_name
  end

  # method to get all the states for a form
  # [['NY New York', 32], ['CA California', 3] ... ]
  #
  # @param [none]
  # @return [ Array[Array] ]
  def self.form_selector
    order('country_id DESC, abbreviation ASC').collect { |state| [state.abbrev_and_name, state.id] }
  end

  # filter all the states for a form for a given country_id
  #
  # @param [Integer] country_id
  # @return [ Arel ]
  def self.all_with_country_id(c_id)
    where(country_id: c_id)
  end
end
