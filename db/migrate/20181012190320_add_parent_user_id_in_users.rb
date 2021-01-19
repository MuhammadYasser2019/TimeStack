class AddParentUserIdInUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :parent_user_id, :integer
  end
end
