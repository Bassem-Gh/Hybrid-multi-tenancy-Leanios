# Modify the switch behavior when it called (Runtime) to switch to a different database before switching tenants.
module Apartment
  module Tenant
    def self.switch!(tenant)
      # establish connection with the tenant database
      tenant_ob = Company.find_by(subdomain: tenant)
      ActiveRecord::Base.establish_connection(tenant_ob.database_config)
      super
    end
  end
end
