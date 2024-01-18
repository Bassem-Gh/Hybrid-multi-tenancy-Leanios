# Modify the switch behavior when it called (Runtime) to switch to a different database before switching tenants.
module Apartment
  module Tenant
    def self.switch!(tenant)
      handle_tenant_database_change(tenant)
      super
    end

    def self.switch(tenant)
      handle_tenant_database_change(tenant)
      super
    end

    private

    def handle_tenant_database_change(tenant)
      if tenant == 'public'
        establish_public_connection
      else
        establish_tenant_connection(tenant)
      end
    end

    def establish_public_connection
      database_value = Rails.configuration.database_configuration[Rails.env]['database']
      ActiveRecord::Base.establish_connection(database_value.to_sym)
    end

    def establish_tenant_connection(tenant)
      database_value = Rails.configuration.database_configuration[Rails.env]['database']
      ActiveRecord::Base.establish_connection(database_value.to_sym)
      tenant_ob = Company.find_by(subdomain: tenant)
      if tenant_ob
        ActiveRecord::Base.establish_connection(tenant_ob.database_config)
      else
        Rails.logger.error("Tenant not found for subdomain: #{tenant}")
      end
    end
  end
end
