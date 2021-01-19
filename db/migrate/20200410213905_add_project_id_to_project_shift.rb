class AddProjectIdToProjectShift < ActiveRecord::Migration[5.2]
  def change
    add_column :project_shifts, :project_id, :integer
  end
end
