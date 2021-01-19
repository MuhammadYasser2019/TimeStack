class AddOvertimeToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :overtime, :boolean , :default => false
  end
end
