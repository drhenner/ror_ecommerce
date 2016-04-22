# adds a coutries' specific states or provinces to the DB
# Look in Rails.root + "db/seed/international_states for the countries you can add.
#
# @usage rake db:add_states country=brazil
namespace :db do
  task :add_states => :environment do

    unless ENV.include?("country")
      puts 'you need to add a country param'
      raise error
    end
    add_country = ENV['country']

    file_to_load  = Rails.root + "db/seed/international_states/#{add_country}_states.yml"
    states_list   = YAML::load( File.open( file_to_load ) )

    states_list.each_pair do |key,state|
      s = State.find_by_abbreviation_and_country_id(state['attributes']['abbreviation'], state['attributes']['country_id'])
      State.create(state['attributes']) unless s
    end
  end
end
