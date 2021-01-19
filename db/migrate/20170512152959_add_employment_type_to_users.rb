class AddEmploymentTypeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :employment_type, :integer
  end
end
