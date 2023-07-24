# README

# 🏢 Multi-Tenant Multi-Database POC 🗄

Welcome to the Multi-Tenant Multi-Database POC repository! This Proof of Concept (POC) showcases an application architecture that efficiently handles multiple tenants across multiple databases. It demonstrates the principles of multi-tenancy, providing data isolation and scalability while optimizing database access for enhanced performance.

## Handling tenant Migrations
In this POC, we've integrated the [Apartment](link/to/apartment-gem) gem to handle multi-tenancy. To configure tenant databases, open the `Apartment.rb` file and add the following code:
```ruby
# config/apartment.rb

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

