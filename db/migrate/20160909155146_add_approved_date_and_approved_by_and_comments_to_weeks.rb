class AddApprovedDateAndApprovedByAndCommentsToWeeks < ActiveRecord::Migration[5.2]
  def change
    add_column :weeks, :approved_date, :datetime
    add_column :weeks, :approved_by, :integer
    add_column :weeks, :comments, :text
  end
end
