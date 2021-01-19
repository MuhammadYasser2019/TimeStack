class AddApprovedByAndRejectedByAndProjectIdToShiftChangeRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :shift_change_requests, :approved_by, :string
    add_column :shift_change_requests, :rejected_by, :string
    add_column :shift_change_requests, :status, :string
    add_column :shift_change_requests, :project_id, :integer
  end
end
