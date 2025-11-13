require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Allow ngrok or custom hosts if needed, or use your production domain(s)
  # config.hosts << "your-production-domain.com"
  # config.hosts << /[a-z0-9-]+\.ngrok-free\.dev/  # Only needed if you use ngrok in production

  # Disable serving static files from the Rails app
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  config.active_storage.service = :local
  config.force_ssl = true

  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }
  config.log_tags = [ :request_id ]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false

  # Use Sidekiq for background jobs (CRUCIAL FOR BULK DIALING)
  config.active_job.queue_adapter = :sidekiq

  config.action_mailer.perform_caching = false
  # ... other production mailer settings ...

  # Enable DNS rebinding protection etc. as needed.
  # config.hosts = [...] # Set to your production domains

  # config.active_job.queue_name_prefix = "autodialer_production" # Optionally namespace jobs
end
