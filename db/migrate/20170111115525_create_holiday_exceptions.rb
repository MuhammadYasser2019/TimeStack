class CreateHolidayExceptions < ActiveRecord::Migration[5.2]
  def change
    create_table :holiday_exceptions do |t|
      t.integer :user_id
      t.integer :project_id
      t.integer :customer_id
      t.text :holiday_ids, array: true

      t.timestamps null: false
    end
  end
end
