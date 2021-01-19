class AddPartialDayToTimeEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :time_entries, :partial_day, :string
  end
end
