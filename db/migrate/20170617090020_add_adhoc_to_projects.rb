class AddAdhocToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :adhoc_pm_id, :integer
    add_column :projects, :adhoc_start_date, :datetime
    add_column :projects, :adhoc_end_date, :datetime
  end
end
