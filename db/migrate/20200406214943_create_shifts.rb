class CreateShifts < ActiveRecord::Migration[5.2]
  def change
    create_table :shifts do |t|
      t.string :name
      t.string :start_time
      t.string :end_time
      t.float :regular_hours
      t.string :incharge
      t.boolean :active
      t.boolean :default
      t.string :location
      t.integer :capacity
      t.integer :customer_id

      t.timestamps
    end
  end
end
