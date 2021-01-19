class AddProjectShiftIdToProjectsUser < ActiveRecord::Migration[5.2]
  def change
    add_column :projects_users, :project_shift_id, :integer
  end
end
