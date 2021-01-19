class AddDefaultProjectAndDefaultTaskToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :default_project, :integer
    add_column :users, :default_task, :integer
  end
end
