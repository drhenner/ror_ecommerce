require 'aws-sdk-s3'

Aws.config.update({
  logger: Rails.logger,
  region: ENV.fetch('AWS_REGION', 'us-west-2'),
  credentials: Aws::Credentials.new(
    ENV.fetch('AWS_ACCESS_KEY_ID', 'test'),
    ENV.fetch('AWS_SECRET_ACCESS_KEY', 'test')
  )
})
