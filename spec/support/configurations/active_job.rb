require 'sidekiq/testing'

RSpec.configure do |config|
  config.include ActiveJob::TestHelper

  config.before do
    ActiveJob::Base.queue_adapter = :test
    Sidekiq::Testing.fake!
  end

  config.after do
    clear_enqueued_jobs
    clear_performed_jobs
    Sidekiq::Worker.clear_all
  end
end
