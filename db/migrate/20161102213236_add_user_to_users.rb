class AddUserToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :user, :boolean
  end
end
