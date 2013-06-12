source 'http://rubygems.org'

## Bundle rails:
gem 'rails', '4.0.0.rc2'

  gem 'uglifier', '>= 1.3.0'
  gem 'sass-rails',   '~> 4.0.0.rc2'

gem "activemerchant", '~> 1.29.3'#, :lib => 'active_merchant'
gem "american_date"
gem 'authlogic', :git => 'git@github.com:christophemaximin/authlogic.git', :branch => 'fix_deprecated_with_scope' #, "3.2.0"
gem "asset_sync"
gem 'awesome_nested_set', :git => "git@github.com:cschramm/awesome_nested_set.git", :branch => 'rails4'
gem 'aws-sdk'
gem 'bluecloth',     '~> 2.1.0'
gem 'cancan', '~> 1.6.8'
gem 'chronic'
#gem 'compass'
#gem 'compass-rails', :git => 'git://github.com/Compass/compass-rails.git', :branch => 'rails4'
gem 'compass-rails', :git => 'git://github.com/milgner/compass-rails.git', :branch => 'rails4'

#  gem 'dalli', '~> 1.0.2'

gem 'dynamic_form'
#gem "friendly_id", "~> 4.0"
gem "friendly_id", :git => "git@github.com:FriendlyId/friendly_id.git", :branch => 'rails4'
gem 'haml',  ">= 3.0.13"#, ">= 3.0.4"#, "2.2.21"#,
gem "jquery-rails"
gem 'jquery-ui-rails'
gem 'json', '~>1.7.7'

#gem 'lazy_high_charts'

#gem 'nested_set'#, '~> 1.7.1'
#gem "nifty-generators", :git => 'git://github.com/drhenner/nifty-generators.git'
gem 'nokogiri', '~> 1.5.0'
gem 'paperclip', '~> 3.0'
gem 'prawn', '~> 0.12.0'
#gem 'protected_attributes'

gem "rails3-generators", :git => "https://github.com/neocoin/rails3-generators.git"
gem "rails_config"
gem 'rmagick',    :require => 'RMagick'

gem 'rake', '~> 10.0.3'

# gem 'resque', require: 'resque/server'

gem 'state_machine', '~> 1.2.0'
#gem 'sunspot_solr', '~> 2.0.0'
#gem 'sunspot_rails', '~> 2.0.0'
gem 'will_paginate', '~> 3.0.4'

#gem 'memcache-client', '~> 1.8.5'
group :production do
  gem 'mysql2', '~> 0.3.11'
  gem 'pg'
end

group :development do
  gem 'sqlite3'
  #gem 'awesome_print'
  #gem 'annotate', :git => 'git://github.com/ctran/annotate_models.git'
  gem "autotest-rails-pure"

  gem "rails-erd"
  gem "debugger"

  # YARD AND REDCLOTH are for generating yardocs
  gem 'yard'
  gem 'RedCloth'
end
group :test, :development do
  gem 'capybara', "~> 1.1"#, :git => 'git://github.com/jnicklas/capybara.git'
  gem 'launchy'
  gem 'database_cleaner', :git => 'git@github.com:bmabey/database_cleaner.git'
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
  #gem "redgreen"
  gem "ZenTest", '4.9.1'#, '4.6.2'

end
