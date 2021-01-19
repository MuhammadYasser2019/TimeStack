class AddPasswordReminderEmailToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :password_reminder_email_sent, :boolean
  end
end
