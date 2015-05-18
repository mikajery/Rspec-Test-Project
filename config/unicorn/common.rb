before_exec do |server|
  # Ensure unicorn picks up our newest Gemfile
  ENV['BUNDLE_GEMFILE'] = "<%= current_path %>/Gemfile"
end

working_directory "#{app_path}/current"

# Unicorn PID file location
pid "#{app_path}/current/tmp/pids/unicorn.pid"

# Path to logs
stderr_path "log/unicorn.stderr.log"
stdout_path "log/unicorn.stdout.log"

# Time-out
timeout 30
