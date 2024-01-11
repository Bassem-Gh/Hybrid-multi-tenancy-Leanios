# Modify the switch behavior when it called (Runtime) to switch to a different database before switching tenants.
module Apartment
  module Tenant
    def self.switch!(tenant)
      return if tenant == 'public'

      # establish connection with the tenant database
      tenant_ob = Company.find_by(subdomain: tenant)
      ActiveRecord::Base.establish_connection(tenant_ob.database_config)
      super
    end

    def self.switch(tenant, &block)
      return if tenant == 'public'

      # establish connection with the tenant database
      tenant_ob = Company.find_by(subdomain: tenant)
      ActiveRecord::Base.establish_connection(tenant_ob.database_config)

      super(tenant, &block)
    end
  end
end
