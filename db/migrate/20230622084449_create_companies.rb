class CreateCompanies < ActiveRecord::Migration[6.1]
  def change
    create_table :companies do |t|
      t.string :email
      t.string :subdomain

      t.timestamps
    end
  end
end
