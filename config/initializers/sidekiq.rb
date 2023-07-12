Sidekiq.configure_client do |config|
    config.redis = { url: ENV.fetch('REDIS_URL', nil), size: 4, network_timeout: 5 }
end

Sidekiq.configure_server do |config|
    config.redis = { url: ENV.fetch('REDIS_URL', nil), size: 4, network_timeout: 5 }

    config.on(:startup) do
        schedule_file = 'config/schedule.yml'

        Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file) if File.exist?(schedule_file)
    end
end
