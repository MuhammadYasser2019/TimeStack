class ChangeTimeEntriesDate < ActiveRecord::Migration[5.2]
  def change
    rename_column :time_entries, :date, :date_of_activity
  end
end
