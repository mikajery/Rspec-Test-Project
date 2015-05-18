Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 5
Delayed::Worker.max_attempts = 5
Delayed::Worker.max_run_time = 2.hours
Delayed::Worker.default_queue_name = 'worker'
Delayed::Worker.raise_signal_exceptions = :term

module WorkerExtensions
  protected

  def handle_failed_job(job, error)
    if !job.payload_object.respond_to?(:error)
      text = "FAILED (#{job.attempts} prior attempts) with #{error.class.name}: #{error.message}"
      text = "Job #{job.name} (id=#{job.id}) #{text}"
      
      if job.attempts >= Delayed::Worker.max_attempts - 1
        log_email('JOB FAILURE!!!', text)
      else
        log_console(text)
      end
    else
      log_console("handle_failed_job SKIPPING email!!")
    end

    super(job, error)
  end
end

def dj_reset(dj)
  dj.attempts = 0
  dj.last_error = dj.run_at = dj.locked_at = dj.failed_at = dj.locked_by = nil
  dj.save!
end

module Delayed
  module DelayMail
    def delay(options = {}, heroku_scale: true, dyno: 'worker', num_dynos: 1)
      if heroku_scale
        current_num_dynos = HerokuTools::HerokuTools.count_dynos(dyno)
        HerokuTools::HerokuTools.scale_dynos(dyno, num_dynos) if current_num_dynos < num_dynos
      end

      DelayProxy.new(PerformableMailer, self, options)
    end
  end

  module MessageSending
    def delay(options = {}, heroku_scale: true, dyno: 'worker', num_dynos: 1)
      if heroku_scale
        current_num_dynos = HerokuTools::HerokuTools.count_dynos(dyno)
        HerokuTools::HerokuTools.scale_dynos(dyno, num_dynos) if current_num_dynos < num_dynos
      end

      DelayProxy.new(PerformableMethod, self, options)
    end
  end

  class Worker
    prepend WorkerExtensions

=begin
    def run(job)
      job_say job, 'RUNNING'
      runtime =  Benchmark.realtime do
        Timeout.timeout(max_run_time(job).to_i, WorkerTimeout) { job.invoke_job }
        job.destroy

        GC.start
        t = Hash.new(0)
        ObjectSpace.each_object(Object) {|o| t[o.class] += 1 }
        #Rails.logger.info(t.to_a.sort_by(&:last)[-10,10].inspect)
        log_console(t.to_a.sort_by(&:last)[-30,25].inspect)
      end
      job_say job, format('COMPLETED after %.4f', runtime)
      return true  # did work
    rescue DeserializationError => error
      job.last_error = "#{error.message}\n#{error.backtrace.join("\n")}"
      failed(job)
    rescue => error
      self.class.lifecycle.run_callbacks(:error, self, job) { handle_failed_job(job, error) }
      return false  # work failed
    end
=end
  end
end
