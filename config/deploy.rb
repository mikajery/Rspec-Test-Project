# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'turing-email'
set :repo_url, "git@github.com:turinginc/#{fetch :application}.git"

# Default branch is :master
if ENV['BRANCH']
  set :branch, ENV['BRANCH']
else
  ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
end

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/#{fetch :application}"

set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.1.5'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

# bower
set :bower_roles, :web
set :bower_target_path, "#{release_path}/vendor/assets"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', '.rbenv-vars', 'config/settings.local.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'vendor/bundle', 'vendor/assets/bower_components', 'public/assets')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5
#
# sidekiq configuration
set :sidekiq_pid, -> { File.join(shared_path, 'tmp', 'pids', 'sidekiq.pid') }
set :sidekiq_log, -> { File.join(shared_path, 'log', 'sidekiq.log') }
set :sidekiq_role, :app
set :sidekiq_default_hooks, true

namespace :deploy do

  desc "Make sure local git is in sync with remote."
  task :check_revision do
    unless `git rev-parse #{fetch :branch}` == `git rev-parse origin/#{fetch :branch}`
      puts "WARNING: HEAD is not the same as origin/#{fetch :branch}"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy:starting", "deploy:check_revision"

  after 'deploy:publishing', 'unicorn:reload'

  before "deploy:updated", "bower:install"

  after "deploy:updated", "newrelic:notice_deployment"

end
