require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Allow Render host for webhooks and production access
  config.hosts << "autodialer-nwzg.onrender.com"
  # Or allow all Render subdomains:
  # config.hosts << /.*\.onrender\.com/

  # Disable serving static files from the Rails app (let nginx/CDN handle it)
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

  # Use inline for background jobs (no separate worker needed)
  config.active_job.queue_adapter = :inline

  config.action_mailer.perform_caching = false

  # Optional: Namespace jobs per environment
  # config.active_job.queue_name_prefix = "autodialer_production"
end
