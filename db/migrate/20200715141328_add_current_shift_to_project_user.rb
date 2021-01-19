class AddCurrentShiftToProjectUser < ActiveRecord::Migration[5.2]
  def change
    add_column :projects_users, :current_shift, :boolean, :default => true
  end
end
