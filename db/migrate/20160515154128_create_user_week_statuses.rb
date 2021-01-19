class CreateUserWeekStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :user_week_statuses do |t|
      t.integer :status_id
      t.integer :week_id
      t.integer :user_id

      t.timestamps null: false
    end
    add_index :user_week_statuses, :week_id
    add_index :user_week_statuses, :user_id
  end
end
