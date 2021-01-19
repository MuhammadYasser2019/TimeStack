class AddStatusIdToWeeks < ActiveRecord::Migration[5.2]
  def change
    add_column :weeks, :status_id, :integer
  end
end
