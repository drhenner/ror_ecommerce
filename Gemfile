source 'https://rubygems.org'
ruby "2.4.0"

## Bundle rails:
gem 'rails', '~> 5.1.3'

gem 'uglifier',     '>= 1.3.0'
# gem 'sass-rails',   '~> 6.0.0.beta1'
gem 'sass-rails',   '~> 5.0.6'

#gem 'actionpack-page_caching', '~> 1.0'
gem "activemerchant", '~> 1.48'#, :lib => 'active_merchant'
gem "american_date",  '~> 1.1.1'

# Use https if you are pushing to HEROKU
##  NOTE: run the test before upgrading to the tagged version. It has had several deprecation warnings.
# gem 'authlogic', '~> 3.4.6'#,          "~> 3.3.0"

gem 'authlogic',   '~> 3.6.0'

#gem 'scrypt', '~> 2.0.0'

gem "asset_sync",         '~> 2.2.0'
gem 'awesome_nested_set', '~> 3.1.3'

gem 'aws-sdk',        '~> 2.3.21'
gem 'bluecloth',      '~> 2.2.0'
gem 'cancancan',      '~> 1.15.0'
gem 'chronic'
# Use https if you are pushing to HEROKU
gem 'compass-rails', ref: '3861c9d9956dd1a5f4290ea87e9d90ba7fe44394'


gem 'dynamic_form'
gem 'jbuilder'
gem "friendly_id",     '~> 5.1.0'#, :git => "git@github.com:FriendlyId/friendly_id.git", :branch => 'rails4'
gem "jquery-rails",    '~> 4.3.1'
gem 'jquery-ui-rails', '~> 6.0.1'
gem 'json',           '~> 2.1.0'

# gem "nifty-generators", :git => 'git://github.com/drhenner/nifty-generators.git'
gem 'nokogiri',     '~> 1.6.5'
gem 'paperclip',    '~> 5.0.0'
gem 'prawn',        '>= 0.12.0'

gem "rails3-generators", "~> 1.0.0"
#git: "https://github.com/neocoin/rails3-generators.git"
gem "config"
gem 'rmagick',    '= 2.15.4', require: false

gem 'rake', '~> 10.1'

# gem 'resque', require: 'resque/server'

# gem "sprockets",       "4.0.0.beta2"
gem "sprockets",       "~> 3.7.0"
gem 'aasm',            '~> 4.12.2'
#gem 'sunspot_solr',   '~> 2.0.0'
#gem 'sunspot_rails',  '~> 2.0.0'
gem 'will_paginate',   '~> 3.1.6'
# gem 'zurb-foundation', '~> 4.3.2'
gem 'foundation-rails', '6.2.3.0'

group :production do
  # gem 'mysql2', '~> 0.4.4'
#  gem 'pg'
#  gem 'rails_12factor'
end

group :development do
  # gem 'sqlite3'
  gem 'railroady'
  #gem 'awesome_print'
  #gem 'annotate', :git => 'git://github.com/ctran/annotate_models.git'
  gem "autotest-rails-pure"
  gem "better_errors", '~> 2.3.0'
  gem "binding_of_caller", '~> 0.7.2'
  # gem "rails-erd"

  # YARD AND REDCLOTH are for generating yardocs
  gem 'yard'
  gem 'RedCloth'
end
group :test, :development do
  gem 'byebug'
  gem 'mysql2',   '~> 0.4.8'
  gem 'capybara', '~> 2.7.1'
  gem 'launchy'
  gem 'database_cleaner', "~> 1.6.1"
end

group :test do
  gem 'factory_girl',       "~> 4.5.0"
  gem 'factory_girl_rails', "~> 4.5.0"
  gem 'mocha',              '~> 0.13.3', :require => false
  gem 'rails-controller-testing'
  gem 'rspec-rails-mocha'
  gem 'rspec-rails',        '~> 3.5'
  gem 'email_spec'
  gem "faker"

end
