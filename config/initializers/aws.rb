require 'aws-sdk'

config_path = File.expand_path(File.dirname(__FILE__)+"/../aws.yml")
config_hash = YAML.load(File.read(config_path))

Aws.config.update({
  logger: Rails.logger,
  region: 'us-west-2',
  credentials: Aws::Credentials.new(config_hash[Rails.env]['access_key_id'], config_hash[Rails.env]['secret_access_key'])
})
