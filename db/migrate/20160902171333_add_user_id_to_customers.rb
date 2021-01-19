class AddUserIdToCustomers < ActiveRecord::Migration[5.2]
  def change
    add_column :customers, :user_id, :integer
  end
end
