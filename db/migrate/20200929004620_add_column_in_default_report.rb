class AddColumnInDefaultReport < ActiveRecord::Migration[5.2]
  def change
    add_column :default_reports, :exclude_inactive_users, :boolean
    
  end
end
