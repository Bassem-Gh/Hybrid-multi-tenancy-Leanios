class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  # connects_to database: {
  #   default: { writing: :primary, reading: :primary },
  #   first_tenant: { writing: :first_tenant, reading: :first_tenant },
  #   second_tenant: { writing: :second_tenant, reading: :second_tenant }
  # connects_to database: {
  #   primary: :primary,
  #   secondary: :first_tenant,
  #   tertiary: :second_tenant
  # }
  # }
  # Primary database connection
  # establish_connection :primary

  # # Second database connection
  # establish_connection :first_tenant

  # # Third database connection
  # establish_connection :second_tenant

  # # Override the connection method to support multiple databases
  # def self.connection
  #   @connection ||= retrieve_connection
  # end
end
