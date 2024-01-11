class CreateEmployees < ActiveRecord::Migration[6.0]
  def up
    create_table :employees do |t|
      t.string :name
      t.integer :age
      t.string :position

      t.timestamps
    end
  end

  def down
    drop_table :employees
  end
end
