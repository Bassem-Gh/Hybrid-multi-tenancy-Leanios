# lib/tasks/apartment_custom_tasks.rake

namespace :apartment do
  desc 'Run migrations for all tenants in a multi-server setup'
  task :migrate_multi_server => :environment do
    Apartment.tenant_names.each do |tenant_name, config|
      # Switch to the tenant's database
      Apartment::Tenant.switch(tenant_name) do
        # Run migrations for this tenant
        Rake::Task['db:migrate'].invoke
      end
    end
  end
end
