require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TuringEmail
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # keys

    config.google_client_id = nil
    config.google_secret = nil

    config.mailgun_api_key = nil
    config.mailgun_public_api_key = nil
    config.mailgun_smtp_username = nil
    config.mailgun_smtp_password = nil

    config.heroku_api_key = nil

    config.google_analytics_key = nil

    config.aws_access_key_id = nil
    config.aws_secret_access_key = nil

    config.active_record.raise_in_transactional_callbacks = true

    config.action_controller.asset_host = Settings.action_controller.asset_host

    #config.log_tags = [ lambda { |request| request.user_agent },
    #                    lambda { |request| request.referrer },
    #                    lambda { |request| request.headers['X-Forwarded-For'] } ]

    if config.respond_to?(:sass)
      require File.expand_path('../../lib/sass_functions.rb', __FILE__)
    end

    GC::Profiler.enable

    config.active_job.queue_adapter = :sidekiq
  end
end
