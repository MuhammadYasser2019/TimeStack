class AddProxyToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :proxy, :boolean
  end
end
