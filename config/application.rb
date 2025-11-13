require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Autodialer
class Application < Rails::Application
config.load_defaults 7.1
config.active_job.queue_adapter = :inline
config.autoload_lib(ignore: %w(assets tasks))
end
end