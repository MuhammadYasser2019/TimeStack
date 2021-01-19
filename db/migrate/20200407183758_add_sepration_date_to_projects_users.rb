class AddSeprationDateToProjectsUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :projects_users, :sepration_date, :datetime, :default => nil
  end
end
