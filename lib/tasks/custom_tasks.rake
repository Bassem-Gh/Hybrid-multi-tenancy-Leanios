namespace :apartment do
  desc 'Run migrations or rollback for all tenants in a multi-server setup'

  task :multi_db, [:task_to_run] => :environment do |_, args|
    task_to_run = args[:task_to_run]

    unless task_to_run.present?
      puts 'Please specify a task to run (e.g., db:migrate, db:rollback, etc.)'
      exit(1)
    end

    Apartment.tenants_with_config.each do |tenant_name, db_config|
      if db_config.present?
        if db_config['database'] != 'primary'
          puts '======================================='
          # Establish the connection to the tenant's database using Apartment's configuration
          #ActiveRecord::Base.establish_connection(db_config)
          puts db_config['database']
          # Log tenant-specific information
          puts '---------------------------------------'
        end
        case task_to_run
        when 'db:migrate'
          puts "Running 'db:migrate' for tenant: #{tenant_name}"
          Apartment::Migrator.migrate tenant_name
          puts "Migration completed for tenant: #{tenant_name}"
        when 'db:rollback'
          puts "Running 'db:rollback' for tenant: #{tenant_name}"
          Apartment::Migrator.rollback tenant_name
          puts "Rollback completed for tenant: #{tenant_name}"
        when 'db:seed'
          puts "Running 'db:seed' for tenant: #{tenant_name}"
          Apartment::Tenant.seed
          puts "Seed completed for tenant: #{tenant_name}"
        else
          puts "Unsupported task: #{task_to_run}"
          exit(1)
        end
        ActiveRecord::Base.establish_connection(:primary)
      else
        puts "No database configuration found for tenant: #{tenant_name}"
      end
    end
  end
end
