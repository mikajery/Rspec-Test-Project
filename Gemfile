source 'https://rubygems.org'

#ruby
ruby '2.1.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'

# Use postgres as the database for Active Record
gem 'pg', '0.18.1'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '~> 2.7.1'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.1'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.0.3'
gem 'jquery-ui-rails', '~> 5.0.3'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.2.12'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.1',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
#gem 'spring',        group: :development

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.10'

# Use unicorn as the app server
gem 'unicorn', '~> 4.8.3'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

# heroku
if ENV['NOT_HEROKU'].nil? # must use NOT_HEROKU because env not available in heroku compile
  gem 'rails_12factor', '~> 0.0.2', group: [:production, :beta]

  # deflater
  gem 'heroku-deflater', '~> 0.5.3'
end

gem "rails_config"

gem 'heroku-api', '~> 0.3.19'

# bootstrap
gem 'bootstrap-sass', '~> 3.2.0.1'
gem 'autoprefixer-rails', '~> 3.0.0.20140821'

# rabl
gem 'rabl', '~> 0.9.3'

# oj - needed for rabl
gem 'oj', '~> 2.7.2'

# swagger
gem 'swagger-docs', '0.1.8'

# aws
gem 'aws-sdk', '~> 1.59.0'

# google api
gem 'google-api-client', '~> 0.7.1'

# rest-client
gem 'rest-client', '~> 1.7.2'

# mail
gem 'mail', '~> 2.5.4'

# Customizable and sophisticated paginator
gem 'kaminari', '~> 0.16.3'

# ejs
gem 'ejs', '~> 1.1.1'

# premailer
gem 'premailer', '~> 1.8.2'

# delayed job
gem 'delayed_job', '~> 4.0.4'
gem 'delayed_job_active_record', '~> 4.0.2'

# gmail oauth
gem 'gmail_xoauth', '~> 0.4.1'

# Do not change foreman version! Doing so causes strange errors.
gem 'foreman', '~> 0.73.0'

gem 'newrelic_rpm'

gem 'dalli'

gem 'bower-rails', '~> 0.9.2'

gem 'simple_enum', '~> 2.0.0'

# rails testing
# keep in development for generators
group :development, :test do
  gem 'rspec-rails', '~> 3.0.1'
  gem 'factory_girl_rails', '4.4.1'
end

group :test do
  gem 'capybara', '~> 2.4.4'
  gem 'capybara-webkit', '~> 1.5.0'
  gem 'selenium-webdriver', '~> 2.45.0'
  gem 'database_cleaner', '~> 1.3.0'
  gem 'simplecov', require: false
  gem 'shoulda-matchers', require: false
  gem 'ffaker'
  gem 'test_after_commit'
end

# Backbone testing framework
group :development, :test do
  gem 'phantomjs', '~> 1.9.7.1'
  gem 'teaspoon', '~> 0.9.1'
  gem 'sinon-rails', '~> 1.10.3'
  gem 'jasmine-sinon-rails', '~> 1.3.4'
  # Annotates active record models and specs
  gem 'annotate'
  # Profiler for ruby rack apps. Better than mini-profiler for api based apps. Need Rails panel to be added to chrome.
  gem 'meta_request'
  # Detect unused eager loading and N+1 queries
  gem "bullet"
  # Mutes assets pipeline log messages
  gem 'quiet_assets'
  # Code metric tool to check the quality of rails code
  gem "rails_best_practices"

  gem "coffeelint"
end

group :development do
  gem 'capistrano'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano3-unicorn'
  gem 'capistrano-rbenv', '~> 2.0'
  gem 'capistrano-rails-console'
  gem 'capistrano-sidekiq'
end

gem 'rack-mini-profiler', require: false
gem 'flamegraph'
gem 'byebug'

gem 'sidekiq'
gem 'sinatra', :require => nil
