class AddDatabaseConfigToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :database_config, :json
  end
end
