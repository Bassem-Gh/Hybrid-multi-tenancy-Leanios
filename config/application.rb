require_relative "boot"
require "rails/all"
# config/application.rb
require 'apartment/elevators/subdomain' # or 'domain', 'first_subdomain', 'host'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HybridMultiTenant
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    config.middleware.use Apartment::Elevators::Subdomain

    #!!!!!!!!
    #config.paths['db/migrate'] = ['db/first_tenant_migrations', 'db/second_tenant_migrations']

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
