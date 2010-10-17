# Load the rails application
require File.expand_path('../application', __FILE__)

# Load custom config file for current environment
raw_config = File.read("config/config.yml")
HADEAN_CONFIG = YAML.load(raw_config)[Rails.env]

CIM_LOGIN_ID = HADEAN_CONFIG['authnet']['login']
CIM_TRANSACTION_KEY = HADEAN_CONFIG['authnet']['password']

#require 'memcache'
#CACHE = MemCache.new(:namespace => "hadean_cache")
#CACHE.servers = 'localhost:11211'

#require 'riak'
#
## Create a client interface
#CACHE = Riak::Client.new
#CACHE.servers = 'localhost:9098'

#Paperclip.options[:command_path] = "/Users/davidhenner/ImageMagick-6.5.9/bin"
Paperclip.options[:command_path] = "/usr/local/bin"

# Initialize the rails application
Hadean::Application.initialize!