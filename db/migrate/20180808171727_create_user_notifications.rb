class CreateUserNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :user_notifications do |t|
      t.integer :user_id
      t.string :notification_type
      t.text :body
      t.integer :count
      t.boolean :seen, default: false
      t.timestamps
    end
  end
end
