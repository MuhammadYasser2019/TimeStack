class AddMobileDataToTimeEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :time_entries, :mobile_data, :boolean , :default => false
    add_column :time_entries, :estimated_time_out, :time
  end
end
