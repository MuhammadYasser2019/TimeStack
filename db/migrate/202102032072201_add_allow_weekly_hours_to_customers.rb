class AddAllowWeeklyHoursToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :allow_weekly_hours, :boolean , :default => false
    add_column :customers, :allow_submit_hours_last_dayofweek, :boolean , :default => false
  end
end
