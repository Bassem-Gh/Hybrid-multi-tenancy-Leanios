puts "MyCustomElevator is loaded!"
# app/middleware/my_custom_elevator.rb
require 'apartment/elevators/generic'

class MyCustomElevator < Apartment::Elevators::Generic
  # @return {String} - The tenant to switch to
  def parse_tenant_name_me(request)
    # Custom logic to determine the tenant name based on the subdomain
    tenant_name = parse_tenant_name_from_subdomainn(request)

    # Look up the Tenant record based on the tenant_name
    tenant = Tenant.find_by(subdomain: tenant_name)

    # Return the database name associated with the tenant
    tenant.database if tenant
  end

  private

  def parse_tenant_name_from_subdomainn(request)
    # Implement your logic to extract the tenant name from the subdomain
    # For example, if your subdomain is in the first part of the domain, you can do:
    # request.host.split('.').first
    request.host.split('.').first
  end
end
