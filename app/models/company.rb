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
