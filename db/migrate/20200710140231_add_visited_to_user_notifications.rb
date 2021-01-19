class AddVisitedToUserNotifications < ActiveRecord::Migration[5.2]
  def change
    add_column :user_notifications, :visited, :boolean, default: false
  end
end
