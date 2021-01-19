class AddProjectShiftIdToTimeEntry < ActiveRecord::Migration[5.2]
  def change
    add_column :time_entries, :project_shift_id, :integer
  end
end
