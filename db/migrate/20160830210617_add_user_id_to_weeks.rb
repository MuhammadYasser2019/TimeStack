class AddUserIdToWeeks < ActiveRecord::Migration[5.2]
  def change
    add_column :weeks, :user_id, :integer
  end
end
