class AddColumnGoogleAccountToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :google_account, :boolean
  end
end
