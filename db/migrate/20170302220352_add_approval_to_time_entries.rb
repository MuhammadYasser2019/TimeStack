class AddApprovalToTimeEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :time_entries, :approved_by, :integer
    add_column :time_entries, :approved_date, :datetime
  end
end
