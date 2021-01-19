class AddInactiveAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :inactive_at, :datetime
  end
end
