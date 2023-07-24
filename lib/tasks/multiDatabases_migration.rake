namespace :db do
  desc "Apply tenants tasks in custom databases, for example  rake db:alter[db:migrate,test-es] applies db:migrate on the database defined as test-es in databases.yml"
  task :alter, [:task,:database] => [:environment] do |t, args|
    #replace it with active_record if it didn't work properly
    require 'active_record'
    puts "Applying #{args.task} on #{args.database}"
    ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[args.database])
    Rake::Task[args.task].invoke
  end
end
