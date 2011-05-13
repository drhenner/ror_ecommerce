source 'http://rubygems.org'

## Bundle rails:
gem 'rails', '~> 3.0.7'

gem "activemerchant", '~> 1.7.2'#, :lib => 'active_merchant'
gem 'authlogic', "2.1.5"
gem 'bluecloth',     '~> 2.1.0'
gem 'cancan', '~> 1.4.1'
gem 'compass', "~> 0.11.0"
gem 'dalli', '~> 1.0.2'

gem 'fancy-buttons'
gem 'formtastic',  "~> 1.1.0"
gem "friendly_id", "~> 3.0"
gem 'haml',  ">= 3.0.13"#, ">= 3.0.4"#, "2.2.21"#,
gem "jquery-rails"

#gem 'memcache-client', '~> 1.8.5'
gem 'mysql2', '~> 0.2.7'

gem 'nested_set', '~> 1.6.3'
gem "nifty-generators", :git => 'git://github.com/drhenner/nifty-generators.git'
gem 'nokogiri', '~> 1.4.4'
gem 'paperclip', '~> 2.3.8'
gem 'prawn', '~> 0.8.4'

gem 'rails3-generators', '~> 0.17.0'
gem 'rmagick',    :require => 'RMagick'

gem 'ssl_requirement'
gem 'state_machine', '~> 0.9.4'
gem 'sunspot_rails', '~> 1.2.rc4'
gem 'will_paginate', '~> 3.0.pre2'

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
  gem "autotest"
  gem "autotest-rails-pure"

  if RUBY_PLATFORM =~ /darwin/
    gem "autotest-fsevent"
  end
  gem "autotest-growl"
  #gem "redgreen"
  #gem "test-unit", "1.2.3"
  #gem "ZenTest"

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





## require 'riak-sessions'
#gem 'curb' # Faster HTTP
#gem 'yajl-ruby' # Faster JSON
#gem 'riak-client', :require => 'riak'
#gem 'ripple'
#gem 'riak-sessions'
#gem 'dalli', '~> 1.0.0'
#gem 'validation_reflection',      :branch => "rails-3"
