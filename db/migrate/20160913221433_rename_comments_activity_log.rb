class RenameCommentsActivityLog < ActiveRecord::Migration[5.2]
  def change
	rename_column :time_entries, :comments, :activity_log
  end
end
