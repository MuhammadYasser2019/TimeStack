class AddExceptionsToTimeEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :time_entries, :sick, :boolean
    add_column :time_entries, :personal_day, :boolean
  end
end
