# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Apartment.tenants_with_config.each do |tenant_name, db_config|
  puts "Running 'migration' for tenant: #{tenant_name}"
  puts db_config
  puts 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  if db_config.present?
    if db_config['database'] == 'primary'
      Rake::Task[task_to_run].invoke # Invoke the task again
      puts ActiveRecord::Base.connection.current_database
      puts 'primary'
    else
      puts'other---------------'
      ActiveRecord::Base.establish_connection(db_config)

      ActiveRecord::Base.connection.migration_context.migrate
    end
  else
    puts "No database configuration found for tenant: #{tenant_name}"
  end
end
