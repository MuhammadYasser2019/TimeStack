class ChangedResetInformation < ActiveRecord::Migration[5.2]
  def change
  	remove_column :archived_weeks,:reset_date
  	add_column :archived_weeks, :reset_date, :datetime
  end
end
