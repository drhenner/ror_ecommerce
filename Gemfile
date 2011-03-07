source 'http://rubygems.org'

## Bundle rails:
gem 'rails', '~> 3.0.3'

gem "activemerchant", '~> 1.7.2'#, :lib => 'active_merchant'
gem 'nested_set', '~> 1.6.3'

gem 'authlogic', "2.1.5"
gem 'cancan', '~> 1.4.1'
gem 'compass', "~> 0.10.6"

gem 'fancy-buttons'
gem "friendly_id", "~> 3.0"
gem 'formtastic',  "~> 1.1.0"#  :git => 'git://github.com/justinfrench/formtastic.git', :branch => "rails3"
gem 'haml',  ">= 3.0.13"#, ">= 3.0.4"#, "2.2.21"#,
gem "jquery-rails"

## require 'riak-sessions'
#gem 'curb' # Faster HTTP
#gem 'yajl-ruby' # Faster JSON
#gem 'riak-client', :require => 'riak'
#gem 'ripple'
#gem 'riak-sessions'

gem 'dalli', '~> 1.0.0'

gem 'nokogiri', '~> 1.4.4'
gem 'memcache-client', '~> 1.8.5'
gem 'mysql2', '~> 0.2.6'

gem "nifty-generators", :git => 'git://github.com/drhenner/nifty-generators.git'
gem 'paperclip', '~> 2.3.8'
gem 'prawn', '~> 0.8.4'

gem 'rails3-generators', '~> 0.17.0'
gem 'rmagick',    :require => 'RMagick'
#gem 'sunspot'
gem 'sunspot_rails', '~> 1.2.rc4'
gem 'ssl_requirement'
gem 'state_machine', '~> 0.9.4'
gem 'will_paginate', '~> 3.0.pre2'
#gem 'validation_reflection',      :branch => "rails-3"

## ADD stuff here if you need them
platforms :ruby_19 do
  gem "ruby-debug19", :group => [:test]
end
platforms :ruby_18 do
  gem "ruby-debug", :group => [:test]
end

group :development do
  #gem 'awesome_print'
  gem "autotest-rails-pure"

  gem "rails-erd"
  gem "ruby-debug19"
  #gem "ruby-debug"
end

group :test do
  gem 'factory_girl_rails'
  gem 'mocha', :require => false
  gem 'rspec-rails-mocha'
  gem "shoulda"
  gem "rspec-rails",  "~> 2.4.0"
  gem "rspec",        "~> 2.4.0"

  gem "rspec-core",         "~> 2.4.0"
  gem "rspec-expectations", "~> 2.4.0"
  gem "rspec-mocks",        "~> 2.4.0"
  gem 'email_spec'

  gem "faker"
  #gem "ZenTest"
  gem "autotest"
  gem "autotest-rails-pure"

  if RUBY_PLATFORM =~ /darwin/
    gem "autotest-fsevent"
  end
  gem "autotest-growl"
  #gem "redgreen"
  #gem "test-unit", "1.2.3"


  ###  THESE ARE ALL FOR CUCUMBER
#  gem "webrat"  ## USE webrat or capybara NOT BOTH
#  gem "capybara"
#  gem "capybara-envjs"
#  gem "database_cleaner"
#  gem "cucumber"
#  gem "cucumber-rails"
#  gem 'spork'
#  gem "launchy"

end
