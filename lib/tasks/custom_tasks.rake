# namespace :db do
#   desc 'Run migrations for all tenants in a multi-server setup'
#   task migrate_multi_server: :environment do
#     # Get the tenant names and configurations defined in Apartment's initializer
#     tenant_configs = Apartment.tenants_with_config

#     tenant_configs.each do |tenant_name, db_config|
#       if db_config.present?
#         # Establish the connection to the tenant's database using Apartment's configuration
#         ActiveRecord::Base.establish_connection(db_config)
#         # Log tenant-specific information
#         puts "Migrating tenant: #{tenant_name}"
#         #puts "Database Configuration: #{db_config}"
#         # Switch to the tenant's schema (assuming you're using PostgreSQL schemas)
#           Apartment::Tenant.switch(tenant_name) do
#             puts "Switched to schema for tenant: #{tenant_name}"
#         # Run migrations for this tenant
#         puts "Running migrations for tenant: #{tenant_name}"
#         Rake::Task['db:migrate'].invoke
#           end

#         # Reset the connection to the primary database after running migrations
#         ActiveRecord::Base.establish_connection(:primary)

#         # Log completion message
#         puts "Migrations completed for tenant: #{tenant_name}"
#       else
#         puts "No database configuration found for tenant: #{tenant_name}"
#       end
#     end
#   end
# end

namespace :db do
  desc 'Run migrations or rollback for all tenants in a multi-server setup'
  task :multi_server, [:task_to_run] => :environment do |_, args|
    require 'active_record'

    task_to_run = args[:task_to_run]

    unless task_to_run.present?
      puts "Please specify a task to run (e.g., db:migrate, db:rollback, etc.)"
      next
    end

    # Get the tenant names and configurations defined in Apartment's initializer
    tenant_configs = Apartment.tenants_with_config

    tenant_configs.each do |tenant_name, db_config|
      if db_config.present?
        # Establish the connection to the tenant's database using Apartment's configuration
        begin
          ActiveRecord::Base.establish_connection(db_config)
          # Log that the connection is successfully established
          puts "======================================="
          puts "Connection established to #{db_config[:database]} for tenant: #{tenant_name}"
          x = ActiveRecord::Base.connection.current_database

          puts x
          # Log tenant-specific information
          puts "======================================="
          puts "Running '#{task_to_run}' for tenant: #{tenant_name}"

          # Switch to the tenant's schema (assuming you're using PostgreSQL schemas)
          #Apartment::Tenant.switch(tenant_name) do
            puts "Switched to schema for tenant: #{tenant_name}"

            # Run the specified task for this tenant
            puts "Running '#{task_to_run}' for tenant: #{tenant_name}"
            Rake::Task[task_to_run].invoke
          #end

          # Reset the connection to the primary database after running the task
          ActiveRecord::Base.establish_connection(:primary)

          # Log completion message
          puts "#{task_to_run.capitalize} completed for tenant: #{tenant_name}"

        rescue StandardError => e
          puts "Error establishing connection for tenant: #{tenant_name}"
          puts "Error message: #{e.message}"
        end
      else
        puts "======================================="
        puts "No database configuration found for tenant: #{tenant_name}"
        puts "======================================="
      end
    end
  end
end
