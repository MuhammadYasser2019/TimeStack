class AddWeekIdToArchivedWeeks < ActiveRecord::Migration[5.2]
  def change
  	add_column :archived_weeks, :week_id, :integer
  end
end
