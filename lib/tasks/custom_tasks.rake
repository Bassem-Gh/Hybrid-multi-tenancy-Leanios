namespace :db do
  desc 'Run migrations or rollback for all tenants in a multi-server setup'

  task :multi_server, [:task_to_run] => :environment do |_, args|
    task_to_run = args[:task_to_run]

    unless task_to_run.present?
      puts 'Please specify a task to run (e.g., db:migrate, db:rollback, etc.)'
      exit(1)
    end

    Apartment.tenants_with_config.each do |tenant_name, db_config|
      if db_config.present?
        if db_config['database'] == 'primary'
          puts "Running '#{task_to_run}' for the primary database directly."
          # Rake::Task[task_to_run].reenable # Re-enable the task
          Rake::Task[task_to_run].invoke # Invoke the task again
          puts "#{task_to_run.capitalize} completed for the primary database."
        else
          #begin
            # Establish the connection to the tenant's database using Apartment's configuration
            ActiveRecord::Base.establish_connection(db_config)

            # Log that the connection is successfully established
            puts '======================================='
            puts ActiveRecord::Base.connection.current_database
            # Log tenant-specific information
            puts '======================================='
            # Switch to the tenant's schema (assuming you're using PostgreSQL schemas)
              #   puts "Switched to schema for tenant: #{tenant_name}"
              # Run the specified task for this tenant
              puts "Running '#{task_to_run} ' for tenant: #{tenant_name}"
              # output = %x{RAILS_ENV=develzopment rails db:migrate 2>&1} # Run and capture output

              # Load Rake tasks dynamically for the current tenant
              #begin
                #puts Rake::Task[task_to_run].execute
                Apartment::Migrator.migrate tenant_name

              #rescue StandardError => e
                # Catch the specific error related to schema not found
                #puts "Schema not found for tenant: #{tenant_name}, continuing..."
               # puts "Error message: #{e.inspect}" # Print the error message
              #end

            # system('RAILS_ENV=development bundle exec rake db:migrate --trace')
            puts "#{task_to_run.capitalize} completed for tenant: #{tenant_name}"
          # rescue StandardError => e
          #   puts "Error establishing connection for tenant: #{tenant_name}"
          #   puts "Error message: #{e.message}"
          #ensure
            # Reset the connection to the primary database after running the task
            ActiveRecord::Base.establish_connection(:primary)
          #end
        end
      else
        puts "No database configuration found for tenant: #{tenant_name}"
      end
    end
  end
end
