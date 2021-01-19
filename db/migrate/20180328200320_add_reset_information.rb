class AddResetInformation < ActiveRecord::Migration[5.2]
  def change
  	add_column :archived_weeks, :reset_by, :integer
  	add_column :archived_weeks, :reset_date, :integer
  end
end
