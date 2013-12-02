source 'http://rubygems.org'
ruby "2.0.0"

## Bundle rails:
gem 'rails', '4.0.1'

gem 'uglifier',     '>= 1.3.0'
gem 'sass-rails',   '~> 4.0.0'

gem 'actionpack-page_caching'
gem "activemerchant", '~> 1.29.3'#, :lib => 'active_merchant'
gem "american_date"
# Use https if you are pushing to HEROKU
gem 'authlogic',          "~> 3.3.0"
#gem 'authlogic',          git: 'git@github.com:binarylogic/authlogic.git'

gem "asset_sync"
gem 'awesome_nested_set', '~> 3.0.0.rc.1'

gem 'aws-sdk'
gem 'bluecloth',      '~> 2.1.0'
gem 'cancan',         '~> 1.6.8'
gem 'chronic'
# Use https if you are pushing to HEROKU
gem 'compass-rails', git: 'https://github.com/Compass/compass-rails.git', branch: 'rails4-hack'
#gem 'compass-rails',  git: 'git://github.com/Compass/compass-rails.git', branch: 'rails4-hack'


gem 'dynamic_form'
gem 'jbuilder'
gem "friendly_id",    '~> 5.0.1'#, :git => "git@github.com:FriendlyId/friendly_id.git", :branch => 'rails4'
gem 'haml',           ">= 4.0.4"#, ">= 3.0.4"#, "2.2.21"#,
gem "jquery-rails"
gem 'jquery-ui-rails'
gem 'json',           '~> 1.8.0'

#gem "nifty-generators", :git => 'git://github.com/drhenner/nifty-generators.git'
gem 'nokogiri',     '~> 1.6.0'
gem 'paperclip',    '~> 3.0'
gem 'prawn',        '~> 0.12.0'

gem "rails3-generators", "~> 1.0.0"
#git: "https://github.com/neocoin/rails3-generators.git"
gem "rails_config"
gem 'rmagick',    :require => 'RMagick'

gem 'rake', '~> 10.1'

# gem 'resque', require: 'resque/server'

gem 'state_machine', '~> 1.2.0'
#gem 'sunspot_solr', '~> 2.0.0'
#gem 'sunspot_rails', '~> 2.0.0'
gem 'will_paginate', '~> 3.0.4'
gem 'zurb-foundation', '~> 4.3.2'

group :production do
  gem 'mysql2', '~> 0.3.12'
  gem 'pg'
  gem 'rails_12factor'
end

group :development do
  gem 'sqlite3'
  gem 'railroady'
  #gem 'awesome_print'
  #gem 'annotate', :git => 'git://github.com/ctran/annotate_models.git'
  gem "autotest-rails-pure"
  gem "better_errors", '~> 0.9.0'
  gem "binding_of_caller", '~> 0.7.2'
  gem "rails-erd"
  gem 'byebug', :platforms => [:mingw_20, :mri_20, :ruby_20]
  gem 'pry-byebug', :platforms => [:mingw_20, :mri_20, :ruby_20]

  # YARD AND REDCLOTH are for generating yardocs
  gem 'yard'
  gem 'RedCloth'
end
group :test, :development do
  gem 'capybara', "~> 1.1"#, :git => 'git://github.com/jnicklas/capybara.git'
  gem 'launchy'
  gem 'database_cleaner', "~> 1.2"
end

group :test do
  gem 'factory_girl', "~> 3.3.0"
  gem 'factory_girl_rails', "~> 3.3.0"
  gem 'mocha', '~> 0.13.3', :require => false
  gem 'rspec-rails-mocha'
  gem 'rspec-rails', '~> 2.12.2'

  gem 'email_spec'

  gem "faker"
  gem "autotest", '~> 4.4.6'
  gem "autotest-rails-pure"

  if RUBY_PLATFORM =~ /darwin/
    #gem "autotest-fsevent", '~> 0.2.5'
  end
  gem "autotest-growl"
  gem "ZenTest", '4.9.1'#, '4.6.2'

end
