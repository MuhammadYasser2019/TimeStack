class CreateDefaultReports < ActiveRecord::Migration[5.2]
  def change
    create_table :default_reports do |t|
      t.integer :customer_id
      t.integer :project_id
      t.integer :user_id
      t.date :start_date
      t.date :end_date
      t.string :month
      t.boolean :current_week
      t.boolean :exclude_pending_user
      t.boolean :billable
      t.timestamps null: false
    end
  end
end
