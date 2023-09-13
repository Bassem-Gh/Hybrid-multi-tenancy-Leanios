class Company < ApplicationRecord
  after_commit :create_tenant

  def create_tenant
    Apartment::Tenant.create(subdomain)
  end
end
