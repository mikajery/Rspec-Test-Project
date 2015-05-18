Sidekiq.configure_client do |config|
  config.redis = Settings.redis.sidekiq.to_hash
end

Sidekiq.configure_server do |config|
  config.options = config.options.merge(Settings.sidekiq.to_hash)
  config.redis = Settings.redis.sidekiq.to_hash
end

require 'sidekiq/web'
Sidekiq::Web.app_url = '/'
Sidekiq.remove_delay!
