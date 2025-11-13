require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true

  # Allow ngrok hosts for webhooks
  config.hosts << "liniest-oversqueamishly-raye.ngrok-free.dev"
  # Or allow any ngrok domain:
  # config.hosts << /[a-z0-9-]+\.ngrok-free\.dev/

  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  config.active_storage.service = :local
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  config.active_support.deprecation = :log
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.active_job.verbose_enqueue_logs = true
  config.assets.quiet = true

  # Fix for Windows Sprockets permission error
  config.assets.configure do |env|
    env.cache = ActiveSupport::Cache.lookup_store(:null_store)
  end
  config.assets.digest = false
  config.assets.debug = true

  config.action_controller.raise_on_missing_callback_actions = true

  # Use Sidekiq for background jobs (IMPORTANT FOR BULK)
  config.active_job.queue_adapter = :inline
end
