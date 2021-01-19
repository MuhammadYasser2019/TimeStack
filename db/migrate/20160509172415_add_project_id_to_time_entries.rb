class AddProjectIdToTimeEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :time_entries, :project_id, :integer
  end
end
