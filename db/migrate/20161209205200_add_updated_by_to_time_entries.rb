class AddUpdatedByToTimeEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :time_entries, :updated_by, :integer
  end
end
