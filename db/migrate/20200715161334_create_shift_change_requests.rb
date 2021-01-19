class CreateShiftChangeRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :shift_change_requests do |t|
      t.integer :user_id
      t.datetime :shift_start_date
      t.datetime :shift_end_date
      t.integer  :shift_id
      t.text :comment

      t.timestamps
    end
  end
end
