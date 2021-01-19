class AddEstimatedTimeToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :estimated_time, :integer
  end
end
