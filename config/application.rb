require_relative 'boot'
require 'rails/all'
require 'apartment/elevators/subdomain' # or 'domain', 'first_subdomain', 'host'
require 'apartment/custom_console'

Bundler.require(*Rails.groups)

module HybridMultiTenant
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.autoload_paths += Dir[Rails.root.join('app', 'models')]
    config.active_job.queue_adapter = :sidekiq
    config.middleware.use Apartment::Elevators::Subdomain
    # config.middleware.use Apartment::Elevators::Host# Use the custom elevator you created
    # config.middleware.use Apartment::Elevators::Generic, proc { |request|
    #   subdomain = request.host.split('.')[0]
    #         # Always establish a connection to the primary database initially to retreive database informations
    #   if subdomain == 'www' || subdomain.nil? || subdomain == 'lvh'
    #     Apartment::Tenant.switch!('public')
    #   else
    #     Apartment::Tenant.switch!(subdomain)
    #   end
    # }
    # config.paths['db/migrate'] = ['db/first_tenant_migrations', 'db/second_tenant_migrations']
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
