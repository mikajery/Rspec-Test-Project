require 'rack-mini-profiler'

Rack::MiniProfilerRails.initialize!(Rails.application)

Rack::MiniProfiler.config.position = 'right'

if defined? HerokuDeflater::SkipBinary
  Rails.application.middleware.delete(Rack::MiniProfiler)
  Rails.application.middleware.insert_after(HerokuDeflater::SkipBinary, Rack::MiniProfiler)
end
