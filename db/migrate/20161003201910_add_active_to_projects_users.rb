class AddActiveToProjectsUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :projects_users, :active, :boolean
  end
end
