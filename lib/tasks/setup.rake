namespace :db do
  task :seed_fake => :environment do
    file_to_load        = Rails.root + "db/seed/config_admin.yml"
    config_information  = YAML::load( File.open( file_to_load ) )
  end
end