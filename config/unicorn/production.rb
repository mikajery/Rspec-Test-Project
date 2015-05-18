app_path = "/var/www/turing-email"

# Unicorn socket
listen "/tmp/unicorn.production.sock"

# Number of processes
# worker_processes 4
worker_processes 2

eval(IO.read("#{File.dirname(__FILE__)}/common.rb"), binding)
