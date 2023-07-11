class AddNewColumnToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :database, :string
  end
end
