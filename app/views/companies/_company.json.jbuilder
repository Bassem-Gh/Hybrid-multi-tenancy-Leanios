json.extract! company, :id, :email, :subdomain, :database_config, :created_at, :updated_at
json.url company_url(company, format: :json)
