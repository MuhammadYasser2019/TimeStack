class ChangeFormatInTimeEntries < ActiveRecord::Migration[5.2]
  def change
    change_column :time_entries, :hours, :float
  end
end
