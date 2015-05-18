Rails.application.configure do
  config.heroku_app_name = 'turing-email-test'

  config.domain = "#{ENV.has_key?('DOMAIN') ? ENV['DOMAIN'] : 'localhost'}"
  config.http_port = "#{ENV.has_key?('HTTP_PORT') ? ENV['HTTP_PORT'] : '4000'}"
  config.http_host = config.domain
  config.http_host += ":#{config.http_port}" if config.http_port != '80'

  config.s3_bucket = 'test.turingemail.com'

  config.smtp_helo_domain = 'localhost'

  config.url = "http://#{config.http_host}"
  config.api_url = "http://#{config.http_host}"

  config.mailgun_domain = 'dev.turingemail.com'

  config.google_client_id = '900985518357-chpj6f40dertjuam39gn8i0bienk8v24.apps.googleusercontent.com'
  config.google_secret = 'NzWBuq2I7Ci04vrElrFE7LQE'

  config.mailgun_api_key = 'key-77f40750a8aa1f3b76d92bccba4e4e59'
  config.mailgun_public_api_key = 'pubkey-9e325d313b41af58399aec7ef0084ba9'
  config.mailgun_smtp_username = 'postmaster@dev.turingemail.com'
  config.mailgun_smtp_password = '5ced9285272c96d6e49ec2105e087bcf'

  config.heroku_api_key = ''

  config.google_analytics_key = ''

  config.aws_access_key_id = 'AKIAIN3HK72G2D43WZGQ'
  config.aws_secret_access_key = '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'

  config.log_level = :info

  # Speed up tests by lowering bcrypt's cost function.
  ActiveModel::SecurePassword.min_cost = true

  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure static asset server for tests with Cache-Control for performance.
  config.serve_static_files  = true
  config.static_cache_control = 'public, max-age=3600'

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  #
  config.cache_store = :null_store
end
