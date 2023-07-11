class Company < ApplicationRecord
  after_commit :create_tenant, :create_schema

  private

  def create_schema

    ActiveRecord::Base.establish_connection(database.to_sym)
    
      ActiveRecord::Base.connection.execute("create schema #{subdomain}")
        scope_schema do
          load Rails.root.join('db/schema.rb')
          ActiveRecord::Base.connection.execute("drop table #{self.class.table_name}")
       end


  end

  def scope_schema(*paths)
    original_search_path = ActiveRecord::Base.connection.schema_search_path
    ActiveRecord::Base.connection.schema_search_path = ["#{subdomain}", *paths].join(',')
    yield
  ensure
    ActiveRecord::Base.connection.schema_search_path = original_search_path
  end

  def create_tenant
    ActiveRecord::Base.establish_connection(database.to_sym)
    Apartment::Tenant.create(subdomain)
    redirect_to root_url(subdomain: company.subdomain)
  rescue StandardError => e
    puts "Error creating tenant: #{e.message}"
    puts e.backtrace
  end
end
