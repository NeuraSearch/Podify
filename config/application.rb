require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Podify
    class Application < Rails::Application
        # Initialize configuration defaults for originally generated Rails version.
        config.load_defaults 7.0

        # Configuration for the application, engines, and railties goes here.
        #
        # These settings can be overridden in specific environments using the files
        # in config/environments, which are processed later.
        #
        # config.time_zone = "Central Time (US & Canada)"
        # config.eager_load_paths << Rails.root.join("extras")

        config.active_storage.variant_processor = :mini_magick
        config.active_storage.service_urls_expire_in = 1.week

        config.action_view.field_error_proc = proc do |html_tag, _instance|
            html_tag.html_safe
        end
    end
end
