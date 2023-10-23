require_relative 'boot'
require 'rails/all'
# config/application.rb
require 'apartment/elevators/subdomain' # or 'domain', 'first_subdomain', 'host'
require 'apartment/custom_console'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HybridMultiTenant
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.autoload_paths += Dir[Rails.root.join('app', 'models')]
    config.active_job.queue_adapter = :sidekiq
    # config.middleware.use Apartment::Elevators::Subdomain
    # config.middleware.use Apartment::Elevators::Host# Use the custom elevator you created
    config.middleware.use Apartment::Elevators::Generic, proc { |request|
      subdomain = request.host.split('.').first

      # Always establish a connection to the primary database initially
      ActiveRecord::Base.establish_connection(:primary)

      if subdomain == 'www' || subdomain.nil?
        Apartment::Tenant.switch!('public')
      else
        # Look up the Tenant record based on the subdomain
        tenant = Company.find_by(subdomain: subdomain)

        if tenant
          # Use the database configuration from the Company model
          #db_config = tenant.database_config(subdomain)
          if tenant.database_config?
            ActiveRecord::Base.establish_connection(tenant.database_config)
            Apartment::Tenant.switch!(tenant.subdomain.to_sym)
          else
            # Handle the case where the database configuration is not found
            Apartment::Tenant.switch!('public')
          end
        else
          # Handle the case where no tenant is found for the subdomain
          Apartment::Tenant.switch!('public')
        end
      end
    }

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
