# README

# 🏢 Multi-Tenant Multi-Database POC 

Welcome to the Multi-Tenant Multi-Database POC repository! This Proof of Concept (POC) showcases an application architecture that efficiently handles multiple tenants across multiple databases. It demonstrates the principles of multi-tenancy, providing data isolation and scalability while optimizing database access for enhanced performance.

## Handling tenant schema creation on the tenant database
`models/company.rb`
```
class Company < ApplicationRecord
  after_commit :create_tenant

  def create_tenant
    if database == 'primary'
      Apartment::Tenant.create(subdomain)
    else
      previous_connection_config = ActiveRecord::Base.connection_config

      # Establish connection to the given database
      ActiveRecord::Base.establish_connection(database.to_sym)
      
      Apartment::Tenant.create(subdomain)

      # Switch back to the primary database
      ActiveRecord::Base.establish_connection(previous_connection_config)
    end
  rescue StandardError => e
    # Handle the exception here
    puts "An error occurred: #{e.message}"
  end
end
```

## Handling tenant Migrations
In this POC, we've integrated the [Apartment](link/to/apartment-gem) gem to handle multi-tenancy. 
1. First, ensure you have the necessary configurations set up in your `databases.yml` file, specifying the databases you want to use for different tenants.
2. To configure tenant , open the `Apartment.rb` file and add the following code:
```ruby

# Enable multi-server setup
config.with_multi_server_setup = true
# Static configuration example for tenant databases
config.tenant_names = {
  'tenant' => {
    adapter: 'postgresql',
    user: 'first_tenant',
    password: 'postgres',
    database: 'multiCompaniesDb', # this is not the name of the tenant's db
    # but the name of the database to connect to before creating the tenant's db
    # mandatory in PostgreSQL
    migrations_paths: 'db/first_tenant_migrations'
  },
  # Add more tenants here if needed
}
```
This configuration sets up the initial static tenants.However, you can also handle tenants dynamically with the following code: 
```
# Enable multi-server setup
config.with_multi_server_setup = true

# Dynamic configuration for tenant databases
config.tenant_names = lambda do
  Tenant.all.each_with_object({}) do |tenant, hash|
    hash[tenant.name] = tenant.db_configuration
  end
end
```
 we've implemented a custom Rake task to handle tenant migrations on different databases . This task enables you to apply tenant-specific tasks, such as database migrations, on a given database.
```
namespace :db do
  desc "Apply tenants tasks in custom databases, for example  rake db:alter[db:migrate,test-es] applies db:migrate on the database defined as test-es in databases.yml"
  task :alter, [:task,:database] => [:environment] do |t, args|
    #replace it with active_record if it didn't work properly
    require 'active_record'
    puts "Applying #{args.task} on #{args.database}"
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[args.database])
    Rake::Task[args.task].invoke
  end
end

3. After creating a new tenant, execute the following command to migrate in the corresponding database:
   ```bash
   rake db:alter[db:migrate, your_database_name]
```
# Middlware config to handle different db connections based on the subdomain 
`application.rb`
```
config.autoload_paths += Dir[Rails.root.join('app', 'models')]
config.middleware.use Apartment::Elevators::Generic, proc { |request|
                                                           subdomain = request.host.split('.').first

                                                           if subdomain == 'www' || subdomain.nil?
                                                             Apartment::Tenant.switch!('public')

                                                           else
                                                             # Look up the Tenant record based on the tenant_name
                                                             ActiveRecord::Base.establish_connection(:primary)
                                                             tenant = Company.find_by(subdomain: subdomain)

                                                             # Switch to the corresponding tenant database
                                                             ActiveRecord::Base.establish_connection(tenant.database.to_sym)
                                                             Apartment::Tenant.switch!(tenant.database)
                                                           end
                                                         }
```
