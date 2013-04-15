
if Settings.uses_resque_for_background_emails && defined?(Resque)
  Hadean::Application.config.after_initialize do
    Resque.redis = $redis
    Resque.redis.namespace = 'resque:rore'
  end
end
