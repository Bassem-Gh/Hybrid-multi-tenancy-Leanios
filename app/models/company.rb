class Company < ApplicationRecord
  attribute :database_config, :json, default: {}
  validate :validate_database_config_keys
  attr_accessor :database_config_adapter, :database_config_host, :database_config_name, :database_config_user,
                :database_config_password, :port

  after_commit :create_tenant

  def update_database_config
    self.database_config = {
      'adapter' => database_config_adapter,
      'host' => database_config_host,
      'database' => database_config_name,
      'user' => database_config_user,
      'password' => database_config_password,
      'port' => port
    }
  end

  def validate_database_config_keys
    required_keys = %w[adapter host database user password port]
    config_hash = database_config || {}

    missing_keys = required_keys - config_hash.keys

    return unless missing_keys.any?

    errors.add(:database_config, "must include the following keys: #{missing_keys.join(', ')}")
  end

  def create_tenant
    if database_config_name == 'primary'
      Apartment::Tenant.create(subdomain)
    else
      previous_connection_config = ActiveRecord::Base.connection_db_config
      tenant_config = database_config # Assuming database_config field contains JSON data
      if tenant_config
        # Establish connection to the given database configuration
        ActiveRecord::Base.establish_connection(tenant_config)
        Apartment::Tenant.create(subdomain)
        # Switch back to the primary database
        ActiveRecord::Base.establish_connection(previous_connection_config)
      else
        puts "--------------Tenant configuration not found for subdomain: #{subdomain}"
      end
    end
  rescue StandardError => e
    # Handle the exception here
    puts "An error occurred: #{e.message}"
  end
end
