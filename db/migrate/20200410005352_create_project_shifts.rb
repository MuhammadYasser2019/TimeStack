class CreateProjectShifts < ActiveRecord::Migration[5.2]
  def change
    create_table :project_shifts do |t|
      t.integer :shift_id
      t.integer :capacity
      t.string :location
      t.integer :shift_supervisor_id

      t.timestamps
    end
  end
end
