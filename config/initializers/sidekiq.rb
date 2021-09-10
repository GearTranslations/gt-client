require 'sidekiq/logstash'
require 'sidekiq-scheduler/web'

redis_url = Rails.application.secrets.redis_url || 'redis://127.0.0.1:6379'

Sidekiq::Logstash.configure do |config|
  config.custom_options = lambda do |payload|
    payload['args'] = payload['args'].to_s.tr('\"', '\'')
  end
end

Sidekiq::Logstash.setup

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }

  config.error_handlers.pop
  config.error_handlers << lambda do |ex, ctx|
    Sidekiq.logger.warn(ex, job: ctx[:job]) # except job_str
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
