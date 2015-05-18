namespace :jobs do
  def fork_delayed(worker_index)
    worker_name = "delayed_job.#{worker_index}"

    worker_pid = fork do
      log_console("DJ WORKER #{worker_name} STARTING!!")
      
      Delayed::Worker.after_fork
      worker = Delayed::Worker.new(@worker_options)
      worker.name_prefix = worker_name
      worker.start

      log_console("DJ WORKER #{worker_name} EXITING!!")
    end

    Rails.logger.info "started #{worker_name} with pid=#{worker_pid}"

    return worker_name, worker_pid
  end
  
  desc "Start a delayed_job worker."
  task :work_multi => :environment_options do    
    if @worker_options[:num_processes] == 1
      Delayed::Worker.new(@worker_options).start
    else
      stop = false

      Signal.trap 'TERM' do
        stop = true
      end

      Delayed::Worker.before_fork

      workers = {}
      @worker_options[:num_processes].times do |worker_index|
        worker_name, worker_pid = fork_delayed(worker_index)
        workers[worker_pid] = worker_name
      end

      worker_index = @worker_options[:num_processes]

      while true
        worker_pid = Process.wait()
        Rails.logger.info "worker #{workers[worker_pid]} exited - #{$?.to_s } STOP=#{stop}"
        break if stop

        worker_name, worker_pid = fork_delayed(worker_index)
        workers[worker_pid] = worker_name

        worker_index = worker_index + 1
      end
    end

    log_console('DJ MASTER EXITING!!')
  end

  task :environment_options => :environment do
    @worker_options = {
        :min_priority => ENV['MIN_PRIORITY'],
        :max_priority => ENV['MAX_PRIORITY'],
        :queues => (ENV['QUEUES'] || ENV['QUEUE'] || '').split(','),
        :quiet => false,
        :num_processes => ENV['NUM_PROCESSES'] ? ENV['NUM_PROCESSES'].to_i : 1
    }

    @worker_options[:sleep_delay] = ENV['SLEEP_DELAY'].to_i if ENV['SLEEP_DELAY']
    @worker_options[:read_ahead] = ENV['READ_AHEAD'].to_i if ENV['READ_AHEAD']
  end
end
