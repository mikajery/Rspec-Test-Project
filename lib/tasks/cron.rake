require 'open-uri'
require 'turing-lib/heroku-tools'
require 'turing-lib/logging'

desc 'Called every 10 minutes - Heroku keep-alive and autoscale'

task :heroku_maintenance => :environment do
  log_exception() do
    startTime = Time.now

    log_console('STARTING heroku_maintenance')

    # heroku keep_alive
    log_exception() do
      log_console('STARTING heroku_maintenance - keep_alive')

      open("#{$config.url}/robots.txt")

      log_console('FINISHED heroku_maintenance - keep_alive')
    end

    # heroku dj_queue_size_check
    log_exception() do
      log_console('STARTING heroku_maintenance - dj_queue_size_check')

      dj_queue_size_alert = ''

      $config.dj_queues.each do |dj_queue|
        jobs_pending = Delayed::Job.where(:queue => dj_queue, :failed_at => nil).count

        dj_queue_size_alert << "#{dj_queue} jobs_pending=#{jobs_pending}\r\n\r\n" if jobs_pending >= $config.dj_queue_alert_size
      end

      log_email('QUEUE size ALERT!!!', dj_queue_size_alert) if !dj_queue_size_alert.blank?

      log_console('FINISHED heroku_maintenance - dj_queue_size_check')
    end

    # heroku scale dynos
    log_exception() do
      log_console('STARTING heroku_maintenance - scale dynos')

      $config.dj_queues_heroku_dynos.each do |queue, dyno|
        if Delayed::Job.where(:queue => queue, :failed_at => nil).count > 0
          num_dynos = HerokuTools::HerokuTools.count_dynos(dyno)

          if num_dynos == 0
            HerokuTools::HerokuTools.scale_dynos(dyno, 1)
          else
            log_console("SKIP scaling #{dyno} because num_dynos=#{num_dynos}")
          end
        else
          HerokuTools::HerokuTools.scale_dynos(dyno, 0)
        end
      end

      log_console('FINISHED heroku_maintenance - scale dynos')
    end

    log_console("EXITING heroku_maintenance #{Time.now - startTime}")
  end
end

desc 'Queue sync account'

task :queue_sync_account => :environment do
  log_exception() do
    startTime = Time.now

    log_console('STARTING queue_sync_account')

    GmailAccount.find_each do |gmail_account|
      log_exception() do
        log_console("PROCESSING account #{gmail_account.email}")

        gmail_account.queue_sync_account()
      end
    end

    log_console("EXITING queue_sync_account #{Time.now - startTime}")
  end
end

desc 'Fetch IP information'

task :fetch_ip_information => :environment do
  # The api allows only 10000 requests per hour hence the limit. Need to add this task in the cron jobs.
  # Let's run it every night for now. We can increase the frequency later on.
  ids = IpInfo.where(fetched: false).select(:id).order('created_at DESC').limit(10000).pluck(:id).to_a

  IpInfo.where(id: ids).find_each do |ip_info|
    begin
      ip_info_json = RestClient.get("https://freegeoip.net/json/#{ip_info.ip.to_s}")
      ip_info_data = JSON.parse(ip_info_json)
      Rails.logger.fatal(ip_info.ip.to_s)
      Rails.logger.fatal(ip_info_data)

      ip_info_data.each do |key, value|
        ip_info[key] = value if ip_info.respond_to?(key)
      end

      ip_info.fetched = true

      ip_info.save!
    rescue Exception
      Rails.logger.info("Error while fetching info for ip: #{ip_info.ip.to_s}")
    end
  end
end