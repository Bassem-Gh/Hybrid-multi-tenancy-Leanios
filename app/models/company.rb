class Company < ApplicationRecord
  after_commit :create_tenant

  def create_tenant
    if database == 'primary'
      Apartment::Tenant.create(subdomain)
    else
      previous_connection_config = ActiveRecord::Base.connection_db_config
      tenant_config = db_configuration(subdomain)
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

  def fetch_all_db_configurations
    [
      {
        'name' => 'tenant1',
        'db_host' => 'localhost',
        'db_port' => 5432,
        'db_name' => 'primary',
        'db_user' => 'postgres',
        'db_password' => 'postgres'
      },
      {
        'name' => 'tenant2',
        'db_host' => 'localhost',
        'db_port' => 5432,
        'db_name' => 'secondary_database',
        'db_user' => 'postgres',
        'db_password' => 'postgres'
      },
      {
        'name' => 'tenant3',
        'db_host' => 'localhost',
        'db_port' => 5432,
        'db_name' => 'secondary_database',
        'db_user' => 'postgres',
        'db_password' => 'postgres'
      },
      {
        'name' => 'mercedes',
        'db_host' => 'localhost',
        'db_port' => 5432,
        'db_name' => 'primary',
        'db_user' => 'postgres',
        'db_password' => 'postgres'
      },
      {
        'name' => 'honda',
        'db_host' => 'localhost',
        'db_port' => 5432,
        'db_name' => 'secondary_database',
        'db_user' => 'postgres',
        'db_password' => 'postgres'
      },
      {
        'name' => 'test',
        'db_host' => 'localhost',
        'db_port' => 5432,
        'db_name' => 'third_database',
        'db_user' => 'postgres',
        'db_password' => 'postgres'
      },
      {
        'name' => 'toyota',
        'db_host' => 'localhost',
        'db_port' => 5432,
        'db_name' => 'third_database',
        'db_user' => 'postgres',
        'db_password' => 'postgres'
      },
      'name' => 'tesla',
      'db_host' => 'localhost',
      'db_port' => 5432,
      'db_name' => 'third_database',
      'db_user' => 'postgres',
      'db_password' => 'postgres'
    ]
  end

  def db_configuration(tenant_name)
    configurations = fetch_all_db_configurations
    config = configurations.find { |c| c['name'] == tenant_name }
    if config
      {
        adapter: 'postgresql',
        host: config['db_host'],
        port: config['db_port'],
        database: config['db_name'],
        username: config['db_user'],
        password: config['db_password'],
        sslmode: nil
      }
    else
      # Handle configuration not found
      {}
    end
  end
end
