class AddTimeInAndTimeOutToTimeEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :time_entries, :time_in, :time
    add_column :time_entries, :time_out, :time
  end
end
