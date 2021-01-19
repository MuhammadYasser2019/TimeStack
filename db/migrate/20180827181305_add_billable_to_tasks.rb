class AddBillableToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :billable, :boolean, :default => false
  end
end
