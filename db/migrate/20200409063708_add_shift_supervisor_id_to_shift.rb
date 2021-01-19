class AddShiftSupervisorIdToShift < ActiveRecord::Migration[5.2]
  def change
    add_column :shifts, :shift_supervisor_id, :integer
  end
end
